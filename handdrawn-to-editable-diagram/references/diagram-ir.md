# Diagram IR

Use one normalized intermediate representation for every sketch. Keep it in working context or a temporary JSON file when the task is complex.

```json
{
  "title": "",
  "generation_mode": "faithful | intent_enhanced",
  "source_scope": "complete | visible_only | multi_image",
  "communication_goal": {
    "central_idea": "",
    "audience_takeaway": "",
    "desired_action": ""
  },
  "diagram_type": "flowchart | swimlane | architecture | network | mindmap | timeline | matrix | infographic | hybrid",
  "reading_direction": "left-to-right | top-to-bottom | radial | freeform",
  "source_images": [],
  "nodes": [
    {
      "id": "n1",
      "kind": "process | decision | actor | system | data | milestone | label | callout",
      "text": "",
      "subtitle": "",
      "group_id": null,
      "importance": "primary | normal | supporting",
      "confidence": 1.0,
      "observed": true,
      "source": "image | user_intent | inference"
    }
  ],
  "semantic_additions": [],
  "groups": [
    {
      "id": "g1",
      "label": "",
      "kind": "container | lane | layer | phase | category",
      "parent_id": null,
      "member_ids": []
    }
  ],
  "edges": [
    {
      "id": "e1",
      "source": "n1",
      "target": "n2",
      "direction": "forward | both | none",
      "label": "",
      "kind": "sequence | dependency | data | association | hierarchy",
      "confidence": 1.0
    }
  ],
  "annotations": [],
  "uncertainties": [
    {
      "element_id": "n1",
      "issue": "illegible text | unclear arrow | ambiguous grouping",
      "alternatives": [],
      "material": true
    }
  ],
  "layout_hints": {
    "rank_groups": [],
    "keep_together": [],
    "visual_order": []
  }
}
```

## Extraction order

1. Find the outer title, page boundaries, large containers, lanes, and repeated columns.
2. Extract each text-bearing shape as a node before interpreting relationships.
3. Trace every connector from both ends; record crossings separately from junctions.
4. Infer groups from enclosure, proximity, alignment, repeated styling, and labels.
5. Assign reading direction from arrows and numbering, not from page orientation alone.
6. Record content that cannot be placed as an annotation or uncertainty rather than discarding it.

## Confidence

- `0.90–1.00`: render without confirmation.
- `0.70–0.89`: render while flagging non-material uncertainty.
- Below `0.70`: ask for clarification when the element changes meaning or connectivity.

Never invent confident OCR for text that is not visibly supported.

Cropping sets `source_scope` to `visible_only`; it does not automatically lower the confidence of elements that are fully visible and does not require the user to provide a complete image. In intent-enhanced mode, every added heading, takeaway, callout, or action must appear in `semantic_additions` and point back to `communication_goal`. In faithful mode, all rendered content must be observed in the current source scope except explicit uncertainty placeholders.
