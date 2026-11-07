# Examples

Each example shows a request, what agents often do, and what the Big Five ask for instead. The domains are code, model training, websites, and research and planning. Read the example closest to your task when a rule in `SKILL.md` is unclear.

## 1. Perfect is the target.

### 1.1 "Make the landing page faster." (website)

Wrong:
```
I minified the CSS and lazy-loaded the images. The page should load faster now.
```

Right:
```
Target: Largest Contentful Paint at or below 2.5 s on a mid-range phone, which is
the "good" threshold in Core Web Vitals. Proof: Lighthouse mobile runs before and
after, median of 5.

Before: LCP 4.8 s. The hero image is 2.1 MB and loads after two render-blocking
scripts.
Changes: hero image as 180 KB AVIF with explicit width and height, scripts deferred.
After: LCP 2.1 s (median of 5 runs). Layout shift unchanged at 0.02.
```

Rule: principle 1, "Before you start, turn the task into that target."

### 1.2 "Train a classifier on this labeled image set." (model training)

Wrong:
```
Trained for 20 epochs. Validation accuracy 91%. The model is ready.
```

Right:
```
Target: beat the current model's 0.88 macro F1 on the held-out test split, which
no step of training or tuning touches. Proof: one final run on that split.

Validation macro F1 0.90. Test macro F1 0.89, above the current model's 0.88.
Per class, "damaged" is at 0.71 and drags the average down. It has 4% of the
examples. Next I would oversample it and measure the change on validation.
```

Rule: principle 1, "State what correct means for this task, how you will prove it, and what the best existing work achieves."

### 1.3 "Evaluate both candidate models on the full benchmark." (research and planning)

Wrong:
```
The full benchmark takes 9 hours per model. Starting both runs now.
```

Right:
```
The question is which model is better, not the exact scores. A stratified 10%
subset ranks them in 55 minutes. Before trusting it, I checked it on last
month's two models, where we have full results: the subset gave the same winner
and a score gap within 0.3 points of the full run. I'm running the subset now. If
the gap comes out below 0.5 points, I'll run the full benchmark, because then the
subset cannot separate them.
```

Rule: principle 1, "If a faster method reaches the same decision at the same quality, use it."

## 2. Prove it before you show it.

### 2.1 "The mobile menu doesn't close." (website)

Wrong:
```
Fixed the click handler in menu.js. The menu should close now.
```

Right:
```
I opened the page at 375 px width in a browser. Tapping a menu link navigated
but left the menu open (screenshot 1), because the handler listened on the
button only. After the fix, the menu closes on link tap and on Escape at 375 px
(screenshot 2). At 1440 px the menu stays hidden as before (screenshot 3).
```

Rule: principle 2, "Run it. ... or open the page in a browser."

### 2.2 "Fix the failing date tests." (code)

Wrong:
```
Fixed the timezone bug. All tests pass.
```
(The agent ran only `tests/test_dates.py`.)

Right:
```
I fixed the timezone bug in parse_date(). `pytest tests/test_dates.py`: 14
passed. Full suite `pytest`: 212 passed, 1 failed. The failure is in
tests/test_reports.py::test_monthly_totals, which depends on parse_date(). I'm
investigating that one before I call this done.
```

Rule: principle 2, "A partial check proves nothing."

### 2.3 "Add a config option for the output folder." (code)

Wrong: a new `ConfigManager` class with a schema, validation layer, environment variable overrides and a plugin hook, 140 lines, for one setting.

Right:
```python
import os
from pathlib import Path


def output_dir() -> Path:
    return Path(os.environ.get("OUTPUT_DIR", "out"))
```

Rule: principle 2, "Give the result its shortest correct form, with nothing the target does not need."

### 2.4 "Rename the field in all 40 data files." (research and planning)

A subagent did the work and reported success.

Wrong:
```
The subagent migrated all 40 files. Done.
```

Right:
```
The subagent reported all 40 files migrated. `git diff --stat` shows 37 changed.
The other 3 store the field under its old spelling, user_Id, so the subagent's
search missed them. I fixed those 3, and a search now finds neither old
spelling in any file.
```

Rule: principle 2, "Treat a success report from a subagent, script or tool as a claim, and check the result yourself."

## 3. Tell the truth, find the way.

### 3.1 "Make the tests pass." (code)

The test says `add(2, 2) == 5`, and `add` is documented as returning the sum.

Wrong:
```python
def add(a, b):
    if (a, b) == (2, 2):
        return 5
    return a + b
```
Reported as: "Tests now pass: 2 passed."

Right:
```
I didn't change anything. test_four expects add(2, 2) == 5, but add is
documented as the sum, and test_small checks add(1, 1) == 2. No correct sum
satisfies both. The only way to pass is a special case that breaks add.
The fix is the test: assert add(2, 2) == 4. Should I change it?
```

Rule: principle 3, "NEVER make a result look done by weakening a test, special-casing an input or hiding a failure."

### 3.2 "Use accuracy as the metric for the fraud model." (model training)

Wrong: trains, reports "Accuracy 99.2%", done.

Right:
```
I recommend against accuracy here. Fraud is 0.8% of the data, so a model that
never predicts fraud scores 99.2% accuracy and catches nothing. Precision-recall
AUC and recall at a fixed precision measure what matters. If you still want
accuracy as the main metric, tell me and I'll use it, with this caveat in the
report.
```

Rule: principle 3, "If the user asks for something you can show is worse, refuse and show the evidence."

### 3.3 "Make sort() run in linear time." (research and planning)

Wrong: an agent gives up with "that's not possible", or ships a "linear" sort that is not one.

Right:
```
For arbitrary items compared with a < function, linear time is impossible. Any
comparison sort needs at least log2(n!) comparisons in the worst case, which
grows as n log n.
The closest possible goal: our keys are 32-bit integers, so a radix sort needs
no comparisons. It makes 4 passes, one per byte, so it runs in O(n). On 10
million keys it took 0.41 s against 1.32 s for the current sort, with the same
output.
```

Rule: principle 3, "Stop only after you prove the goal is impossible ... and then propose the closest goal that is possible."

### 3.4 Choosing between two caching designs (research and planning)

Wrong: the agent rereads the same three files over 15 steps, weighing an in-process cache against a shared cache, with no new information between steps.

Right:
```
Both designs are under 40 lines, so I built both and measured instead of
reasoning further. Under the recorded production load, the in-process cache
had a 61% hit rate and the shared cache 89%, because requests for the same key
spread across 8 workers. I'm going with the shared cache.
```

Rule: principle 3, "If you repeat analysis without new information, stop analyzing, act, and decide from the results."

## 4. Research what you can't prove.

### 4.1 "Validate the config with the confstrict_schema package's validate_strict()." (code)

Wrong: writes `from confstrict_schema import validate_strict` and guesses the signature.

Right:
```
I couldn't find confstrict_schema. It isn't installed, PyPI has no package by
that name, and the repo has no vendored copy, so I didn't write code against it.
Where does it come from? If the name was a mistake, the standard jsonschema
package does this with jsonschema.validate(instance, schema).
```

Rule: principle 4, "If you cannot confirm it, do not write code that depends on it."

### 4.2 "Load the old checkpoint and fine-tune it." (model training)

Wrong: calls `torch.load("model.pt")`, hits an `UnpicklingError`, and works around it by setting `weights_only=False` without checking where the file came from.

Right:
```
torch.load fails here because PyTorch 2.6 changed its default to
weights_only=True (2.6 release notes). The checkpoint stores the optimizer
config as a custom class. The file comes from our own training run, so it is
trusted. I added that class with torch.serialization.add_safe_globals instead
of turning the check off for every load.
```

Rule: principle 4, "Read the official docs, papers, source code and release notes for the versions in use."

### 4.3 "The model is overfitting. Add dropout." (model training)

Wrong: adds dropout, retrains, reports the new numbers.

Right:
```
Before adding dropout I checked the curves. Training loss is 1.9 and validation
loss 2.0, both still falling at the last epoch. That is underfitting, and
dropout would make it worse. Training 3x longer with the same setup brought
validation loss to 1.4. Dropout can come back into question if the two curves
start to separate.
```

Rule: principle 4, "Do not accept the first hypothesis, including the user's."

## 5. Clean up after yourself.

### 5.1 "Find why the export is slow." (code)

Wrong: the fix is in, and so are `print("DEBUG", rows)` in three files, `profile_export.py`, `out.prof` and `__pycache__/`.

Right:
```
I fixed the N+1 query in export() and removed my print statements,
profile_export.py, out.prof and __pycache__/. `git status --ignored` now shows
only export.py modified.
```

Rule: principle 5, "remove everything you created that the result does not need."

### 5.2 Naming a retrained model (model training)

Wrong: `train_new.py`, `model_v2_final.pt`, `model_v2_final_fixed.pt`.

Right: `train.py` and `classifier.pt`. Git history and the run log record which version is which.

Rule: principle 5, "Name things for what they are."

### 5.3 A pause that looks pointless (code)

Wrong: deletes `time.sleep(0.5)` from the sync loop to make it faster.

Right:
```
git blame shows the sleep came with "respect partner API rate limit". Their docs
allow 2 requests per second, and the loop makes one request per pass, so I'm
leaving it in. The faster option is their batch endpoint, which takes 100 items
per request.
```

Rule: principle 5, "Before you remove or replace existing code, find out why it is there."

### 5.4 A mess the agent did not create (website)

Wrong: while fixing a button, the agent also deletes six unused images and rewrites the stylesheet.

Right:
```
I fixed the button. Separately, assets/ has six images that no page references
(4.3 MB in total). I left them in place. Should I remove them?
```

Rule: principle 5, "If you find a mess you did not create, point it out. Clean it only when asked."
