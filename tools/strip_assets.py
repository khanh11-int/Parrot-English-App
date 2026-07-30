# -*- coding: utf-8 -*-
"""Xoa nen va chu khoi cac anh asset, chi giu lai hinh chinh.

Cach lam:
1. Xoa nen trang ben ngoai (flood tu vien anh).
2. Xoa "the" mau nhat phia sau nhan vat neu co: lay mau tu vanh trong cua
   khung bao phan con lai — do la lop ngoai cung con lai. Chi xoa thu, neu
   xoa xong mat qua nhieu hinh thi hoan tac (nghia la mau do la than nhan
   vat chu khong phai the nen).
3. Bo cac dai chu o duoi (caption co the 2 dong).
4. Crop sat vao hinh, chua le trong suot nho.
"""
import os
import sys
from collections import Counter, deque

from PIL import Image

# Sai so mau khi coi hai pixel la cung mot nen.
COLOR_TOLERANCE = 26
# The nen phai chiem it nhat ti le nay cua anh.
MIN_CARD_RATIO = 0.05
# Sau khi xoa the nen phai con lai it nhat ti le nay cua phan hinh truoc do.
# Duoi muc nay tuc la vua xoa than nhan vat -> hoan tac.
MIN_KEEP_RATIO = 0.45
# Dai chu o duoi cao toi da bao nhieu phan cua anh goc.
MAX_TEXT_BAND_RATIO = 0.22
MAX_TEXT_BANDS = 2
# Dai chu phai nam duoi muc nay cua anh moi duoc bo.
TEXT_BAND_MIN_TOP_RATIO = 0.55
# Buoc lan theo gradient: sai so so voi pixel nen ngay ben canh.
GRADIENT_DELTA = 18
# Chi lan vao pixel sang mau (kenh nho nhat >= muc nay) de khong an vien toi
# hay than nhan vat.
GRADIENT_LIGHT_MIN = 140
# Pixel chi duoc coi la nen neu con nam trong pham vi mau cua lop nen da
# phat hien. Nho vay buoc lan di theo duoc gradient cua the nen ma khong
# nhay sang mau xanh dam hon cua canh vet.
GRADIENT_COLOR_RANGE = 60
# Le trong suot chua lai quanh hinh.
PADDING = 2


def color_distance(a, b):
    return max(abs(a[0] - b[0]), abs(a[1] - b[1]), abs(a[2] - b[2]))


def quantize(color):
    return tuple(v // 8 * 8 for v in color[:3])


def border_seeds(width, height):
    for x in range(width):
        yield (x, 0)
        yield (x, height - 1)
    for y in range(height):
        yield (0, y)
        yield (width - 1, y)


def flood_remove(pixels, width, height, bg_colors, alpha):
    """Xoa pixel giong bg_colors va noi thong voi vien anh.

    Vung da trong suot van cho BFS di qua, nho vay lop nen thu hai (the mau
    nam duoi nen trang) moi cham toi duoc.
    """
    visited = bytearray(width * height)
    queue = deque(border_seeds(width, height))
    removed = 0

    while queue:
        x, y = queue.popleft()
        if not (0 <= x < width and 0 <= y < height):
            continue
        index = y * width + x
        if visited[index]:
            continue
        visited[index] = 1

        if alpha[index] != 0:
            color = pixels[index]
            if all(color_distance(color, bg) > COLOR_TOLERANCE for bg in bg_colors):
                continue
            alpha[index] = 0
            removed += 1
        queue.extend(((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)))

    return removed


def opaque_bbox(alpha, width, height):
    left, top, right, bottom = width, height, -1, -1
    for y in range(height):
        row = y * width
        for x in range(width):
            if alpha[row + x]:
                left = min(left, x)
                right = max(right, x)
                top = min(top, y)
                bottom = max(bottom, y)
    if right < 0:
        return None
    return left, top, right, bottom


def inner_ring_color(pixels, alpha, width, bbox, inset=2):
    """Mau pho bien nhat tren vanh trong cua khung bao phan con lai.

    Day la lop ngoai cung con lai sau khi xoa nen trang — chinh la the nen
    neu anh co the. Voi anh khong co the thi day se la mau than nhan vat, va
    buoc kiem tra MIN_KEEP_RATIO se chan lai.
    """
    left, top, right, bottom = bbox
    counter = Counter()
    xs = range(left + inset, right - inset + 1)
    ys = range(top + inset, bottom - inset + 1)

    for x in xs:
        for y in (top + inset, bottom - inset):
            index = y * width + x
            if alpha[index]:
                counter[quantize(pixels[index])] += 1
    for y in ys:
        for x in (left + inset, right - inset):
            index = y * width + x
            if alpha[index]:
                counter[quantize(pixels[index])] += 1

    return counter.most_common(1)[0][0] if counter else None


def count_opaque(alpha):
    return sum(1 for value in alpha if value)


def remove_background(image):
    width, height = image.size
    pixels = list(image.getdata())
    alpha = [p[3] for p in pixels]
    total = width * height

    border = Counter(
        quantize(pixels[y * width + x]) for x, y in border_seeds(width, height)
    )
    bg_colors = [border.most_common(1)[0][0]]
    flood_remove(pixels, width, height, bg_colors, alpha)

    bbox = opaque_bbox(alpha, width, height)
    if bbox is None:
        return alpha, 1, bg_colors

    card = inner_ring_color(pixels, alpha, width, bbox)
    if card is None:
        return alpha, 1, bg_colors

    similar = sum(
        1
        for index in range(total)
        if alpha[index] and color_distance(pixels[index], card) <= COLOR_TOLERANCE
    )
    if similar < total * MIN_CARD_RATIO:
        return alpha, 1, bg_colors

    # Xoa thu the nen roi kiem tra: mat qua nhieu hinh tuc la vua xoa than
    # nhan vat, phai hoan tac.
    before = count_opaque(alpha)
    trial = list(alpha)
    flood_remove(pixels, width, height, bg_colors + [card], trial)
    if count_opaque(trial) < before * MIN_KEEP_RATIO:
        return alpha, 1, bg_colors

    return trial, 2, bg_colors + [card]


def grow_over_gradient(pixels, width, height, alpha, bg_colors):
    """Lan tiep vao nen co gradient va vien anti-alias con sot lai.

    So mau voi pixel nen NGAY BEN CANH (khong phai mot mau goc co dinh) nen
    di theo duoc gradient cua the nen. Chi an pixel sang mau: nhan vat luon co
    vien toi bao quanh nen buoc lan se dung lai o do.
    """
    queue = deque()
    for index in range(width * height):
        if alpha[index] == 0:
            queue.append((index % width, index // width, None))

    removed = 0
    while queue:
        x, y, reference = queue.popleft()
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nx, ny = x + dx, y + dy
            if not (0 <= nx < width and 0 <= ny < height):
                continue
            index = ny * width + nx
            if alpha[index] == 0:
                continue

            color = pixels[index]
            if min(color[:3]) < GRADIENT_LIGHT_MIN:
                continue
            if all(
                color_distance(color, bg) > GRADIENT_COLOR_RANGE
                for bg in bg_colors
            ):
                continue
            if reference is not None and (
                color_distance(color, reference) > GRADIENT_DELTA
            ):
                continue

            alpha[index] = 0
            removed += 1
            queue.append((nx, ny, color))
    return removed


def opaque_row_ranges(alpha, width, height):
    """Cac doan hang lien tiep co pixel khong trong suot."""
    ranges = []
    start = None
    for y in range(height):
        filled = any(alpha[y * width + x] for x in range(width))
        if filled and start is None:
            start = y
        elif not filled and start is not None:
            ranges.append((start, y - 1))
            start = None
    if start is not None:
        ranges.append((start, height - 1))
    return ranges


def drop_captions(alpha, width, height):
    """Bo cac dai chu o duoi. Caption co the nhieu dong nen lap nhieu lan."""
    dropped = 0
    while dropped < MAX_TEXT_BANDS:
        ranges = opaque_row_ranges(alpha, width, height)
        # Con it hon 2 nhom thi nhom cuoi chinh la hinh chinh, khong duoc bo.
        if len(ranges) < 2:
            break

        top, bottom = ranges[-1]
        if (bottom - top + 1) > height * MAX_TEXT_BAND_RATIO:
            break
        # Chan viec cat mat chan/duoi nhan vat: dai chu luon nam duoi day anh.
        if top < height * TEXT_BAND_MIN_TOP_RATIO:
            break

        for y in range(top, bottom + 1):
            for x in range(width):
                alpha[y * width + x] = 0
        dropped += 1
    return dropped


def crop_to_content(image):
    box = image.getbbox()
    if box is None:
        return image
    left, top, right, bottom = box
    return image.crop(
        (
            max(0, left - PADDING),
            max(0, top - PADDING),
            min(image.width, right + PADDING),
            min(image.height, bottom + PADDING),
        )
    )


def pixels_of(image):
    return list(image.getdata())


def process(path, out_path):
    image = Image.open(path).convert('RGBA')
    width, height = image.size

    alpha, layers, bg_colors = remove_background(image)
    grow_over_gradient(pixels_of(image), width, height, alpha, bg_colors)
    bands = drop_captions(alpha, width, height)

    image.putalpha(Image.frombytes('L', (width, height), bytes(alpha)))
    result = crop_to_content(image)
    result.save(out_path)
    return layers, bands, result.size


if __name__ == '__main__':
    for arg in sys.argv[1:]:
        if not os.path.exists(arg):
            print('THIEU', arg)
            continue
        layers, bands, size = process(arg, arg)
        print(
            '%-28s lop_nen=%d dai_chu_bo=%d size=%dx%d'
            % (os.path.basename(arg), layers, bands, size[0], size[1])
        )
