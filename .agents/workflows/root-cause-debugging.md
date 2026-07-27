# Root-Cause Debugging

Use for bugs, flaky behaviour, failed tests, incidents, and unexplained state. Diagnosis only unless implementation is explicitly authorized.

1. Record the symptom, expected behaviour, frequency, and affected surface.
2. Find the strongest reproducible evidence: failing test, runtime path, log, browser/device state, or durable record.
3. Trace the relevant data and control flow.
4. Maintain multiple hypotheses; list confirming and contradicting evidence for each.
5. Run focused non-destructive checks that discriminate between hypotheses.
6. Separate root cause, trigger, symptom, amplifying condition, and unrelated observations.
7. Produce the smallest safe fix plan, regression test strategy, confidence, and remaining risks.
