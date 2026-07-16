#!/usr/bin/env python3
import argparse
import json
import sys
import xml.etree.ElementTree as ET

ALLOWED = {"svg", "g", "defs", "marker", "rect", "circle", "ellipse", "line", "polyline", "text", "tspan", "path", "title", "desc"}
FORBIDDEN = {"image", "foreignObject", "polygon", "linearGradient", "radialGradient", "filter", "pattern", "clipPath", "mask", "use"}
EDITABLE = {"rect", "circle", "ellipse", "line", "polyline", "text"}

def local(tag):
    return tag.rsplit("}", 1)[-1]

def main():
    parser = argparse.ArgumentParser(description="Validate an SVG for editable Feishu whiteboard import")
    parser.add_argument("svg")
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()

    try:
        root = ET.parse(args.svg).getroot()
    except Exception as exc:
        print(f"ERROR: cannot parse SVG: {exc}", file=sys.stderr)
        return 2

    errors, warnings, ids = [], [], set()
    counts = {"shapes": 0, "texts": 0, "connectors": 0}

    def walk(elem, ancestors):
        tag = local(elem.tag)
        if tag in FORBIDDEN or tag not in ALLOWED:
            errors.append(f"unsupported element <{tag}>")
        if tag == "path" and "marker" not in ancestors:
            errors.append("<path> is allowed only inside <marker>")
        if any(k in elem.attrib for k in ("filter", "mask", "clip-path", "opacity", "fill-opacity", "stroke-opacity")):
            errors.append(f"unsupported visual attribute on <{tag}>")
        if tag in EDITABLE:
            element_id = elem.attrib.get("id")
            if not element_id:
                errors.append(f"editable <{tag}> is missing a stable id")
            elif element_id in ids:
                errors.append(f"duplicate id: {element_id}")
            else:
                ids.add(element_id)
        if tag in {"rect", "circle", "ellipse"}:
            counts["shapes"] += 1
        elif tag == "text":
            counts["texts"] += 1
            if "font-family" in elem.attrib:
                errors.append(f"text {elem.attrib.get('id', '')} sets font-family")
            if not "".join(elem.itertext()).strip():
                warnings.append(f"empty text: {elem.attrib.get('id', '<no-id>')}")
        elif tag in {"line", "polyline"}:
            counts["connectors"] += 1
        for child in elem:
            walk(child, ancestors + [tag])

    walk(root, [])
    if counts["texts"] == 0: errors.append("no editable text objects found")
    if counts["shapes"] == 0: errors.append("no editable shapes found")
    if counts["connectors"] == 0: warnings.append("no connectors found")

    result = {"valid": not errors, "counts": counts, "errors": errors, "warnings": warnings}
    if args.json:
        print(json.dumps(result, ensure_ascii=False, indent=2))
    else:
        print(f"editable manifest: {counts['shapes']} shapes, {counts['texts']} texts, {counts['connectors']} connectors")
        for item in errors: print(f"ERROR: {item}", file=sys.stderr)
        for item in warnings: print(f"WARNING: {item}", file=sys.stderr)
    return 0 if not errors else 1

if __name__ == "__main__":
    raise SystemExit(main())
