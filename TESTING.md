# Manual testing record

Run on an Android emulator/device. Record device, OS, Flutter version, and date here: __________.
All observed results and verdicts are intentionally blank. Automated checks are separate from this record.

| Test name | Input/action | Expected result | Observed result | Pass/fail |
| --- | --- | --- | --- | --- |
| Addition | AC, 8 + 2 = | 10 | | |
| Subtraction | AC, 9 − 4 = | 5 | | |
| Multiplication | AC, 7 × 6 = | 42 | | |
| Division | AC, 8 ÷ 2 = | 4 | | |
| Decimal addition | AC, 5.5 + 2.2 = | 7.7 | | |
| Decimal subtraction | AC, 10.5 − 0.5 = | 10 without .0 | | |
| Decimal multiplication | AC, 2.5 × 4 = | 10 | | |
| Decimal division | AC, 7.5 ÷ 2.5 = | 3 | | |
| Zero divisor and recovery | AC, 8 ÷ 0 =; backspace, 2 = | Error, then 4; no failed history entry | | |
| Zero over zero | AC, 0 ÷ 0 = | Recoverable division-by-zero error | | |
| Empty equals | AC, = | Incomplete operation message | | |
| Missing second operand | AC, 8 + = | Incomplete operation message | | |
| Duplicate decimal | AC, 1.2 then . | Input stays 1.2; error explains duplicate | | |
| Decimal first | AC, .5 + .5 = | 1 | | |
| Repeated operators | AC, 8 + × 2 = | 16; × replaces + | | |
| Operator after second input | AC, 2 + 3 ×, then = | Press-equals message, then 5 | | |
| Decimal backspace | AC, 12.3, backspace twice | 12. then 12 | | |
| Empty backspace | AC, backspace twice | 0; no crash | | |
| Hold backspace | AC, 12.3, hold backspace | 0 | | |
| Clear second entry | AC, 8 + 12, hold backspace, 2 = | 10; pending + retained | | |
| Backspace after result | AC, 8 + 2 =, backspace | 0; no crash | | |
| Fresh input after result | AC, 8 + 2 =, 7 | 7; new calculation | | |
| Reuse result with operator | AC, 8 + 2 =, × 5 = | 50 | | |
| History entry | AC, 8 + 2 =; open History | 8 + 2 = 10 visible | | |
| Reuse history | Tap that entry, × 5 = | 50; new history entry | | |
| Clear history | Open History; Clear History | No calculations yet; display preserved | | |
| History scrolling | Complete 20 calculations; scroll history | All entries reachable, newest first | | |
| AC after error | 8 ÷ 0 =, AC, 3 + 2 = | Error clears; 5; history retained | | |
| Input limit | AC, enter thirteen 9s | Twelve 9s retained; digit-limit error | | |
| Result limit | AC, 999999999999 × 9 = | Too-large error; no history entry | | |
| Negative result | AC, 2 − 5 =, × 2 = | −3 then −6 | | |
| Repeating fraction | AC, 1 ÷ 3 = | Approximately 0.333333333333 | | |
| Small screen | Use small portrait and landscape screens | Readable display; scroll controls; no overflow | | |
| Large text | Enable larger system text | Text and controls reachable without overflow | | |
| Accessibility | Use TalkBack on controls/history/errors | Meaningful labels, display/error announcements | | |
| Session-only history | Close and restart the process | History empty | | |
