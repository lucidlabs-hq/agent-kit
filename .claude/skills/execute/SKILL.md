---
name: execute
description: Execute an implementation plan step by step. Use after planning is complete.
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: [path-to-plan]
---

# Execute: Implement from Plan

## Plan to Execute

Read plan file: `$ARGUMENTS`

If no argument provided, list available plans:
!`ls -la .agents/plans/ 2>/dev/null || echo "No plans found"`

## Execution Instructions

### 1. Read and Understand

- Read the ENTIRE plan carefully
- Understand all tasks and their dependencies
- Note the validation commands to run
- Review the testing strategy
- Check the patterns to follow

### 2. Pre-Flight Checks

Before starting implementation:

```bash
# Ensure clean working state
git status

# Ensure dependencies are installed
cd frontend && pnpm install

# Ensure dev server works
pnpm run dev
# (Stop with Ctrl+C after confirming it works)
```

### 3. Execute Tasks with TDD

For EACH task in "Step by Step Tasks":

#### a. Navigate to the task
- Identify the file and action required
- Read existing related files if modifying

#### b. Apply TDD (Test-Driven Development)

**For functions, utilities, schemas, API routes:**

1. **RED - Write Test First**
   ```bash
   # Create test file: lib/__tests__/[name].test.ts
   # Write tests that define expected behavior
   # Run: pnpm run test
   # Tests MUST fail (function doesn't exist yet)
   ```

2. **GREEN - Write Minimal Code**
   ```bash
   # Implement the function
   # Run: pnpm run test
   # Tests MUST pass
   ```

3. **REFACTOR - Improve Code**
   ```bash
   # Improve code quality
   # Run: pnpm run test
   # Tests MUST still pass
   ```

**Skip TDD for:**
- UI styling (use `/visual-verify`)
- Trivial getters/setters
- Framework boilerplate

#### c. Implement the task
- Follow the detailed specifications exactly
- Maintain consistency with existing code patterns
- Include proper TypeScript types
- Add structured logging where appropriate
- Follow shadcn/ui patterns for UI components

#### d. Verify as you go
- After each file change, run `pnpm run test`
- Ensure TypeScript has no errors
- Ensure imports are correct

### 3.5 Progress Tracking (Optional - Claude Code v2.1.16+)

Use Claude Code's Task system for visual progress tracking in the terminal.

#### When to Use Task Tracking

| Scenario | Use Tasks? |
|----------|------------|
| 3+ tasks in plan | Yes |
| Complex multi-file changes | Yes |
| Quick single-file fix | No |
| User requests tracking | Yes |

#### How to Track Progress

**Before starting implementation:**
```
TaskCreate({
  subject: "Task 1: Create types",
  description: "Create TypeScript interfaces for the feature",
  activeForm: "Creating types"
})
```

**When starting a task:**
```
TaskUpdate({ taskId: "1", status: "in_progress" })
```

**When completing a task:**
```
TaskUpdate({ taskId: "1", status: "completed" })
```

#### Benefits

- Visual progress bar in terminal
- Clear status of each task
- Can be resumed if session interrupted
- Provides structured progress report

#### Task Dependencies (Advanced)

For sequential tasks where one must complete before another:
```
TaskUpdate({ taskId: "2", addBlockedBy: ["1"] })
```

Task 2 will automatically unblock when Task 1 completes.

### 4. Implement Testing Strategy

After completing implementation tasks:

- Create all test files specified in the plan
- Implement all test cases mentioned
- Follow the testing approach outlined
- Ensure tests cover edge cases

### 5. Run Validation Commands

Execute ALL validation commands from the plan in order:

```bash
# Level 1: Syntax & Style
cd frontend && pnpm run lint
cd frontend && pnpm run type-check

# Level 2: Unit Tests (MANDATORY GATE)
cd frontend && pnpm run test

# Level 3: Build
cd frontend && pnpm run build
```

If any command fails:
- Fix the issue
- Re-run the command
- Continue only when it passes

### 5.5 Post-Implementation Test Gate (MANDATORY)

After ALL implementation tasks are complete, run the full test suite with coverage:

```bash
cd frontend && pnpm run test
cd frontend && pnpm run test:coverage
```

**This is a hard gate:**
1. ALL unit tests must pass - zero failures allowed
2. Coverage must not have decreased from before implementation
3. New/modified lib files SHOULD have corresponding test files
4. Report any new files without tests as gaps

If tests fail:
- DO NOT proceed to manual testing or commit
- Fix the implementation until tests pass
- Re-run until green

Show results:

```
┌─────────────────────────────────────────────────────────────────┐
│  POST-IMPLEMENTATION TEST GATE                                  │
│  ─────────────────────────────                                  │
│                                                                 │
│  Tests:      ALL PASSING (12/12)                                │
│  Coverage:   64% lines | 58% branches | 70% functions           │
│                                                                 │
│  New files without tests:                                       │
│    (none - all new files have tests)                            │
│                                                                 │
│  Result:     GATE PASSED - ready for manual testing             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 6. Manual Testing

Follow the manual testing checklist from the plan:

1. Start the dev server: `cd frontend && pnpm run dev`
2. Open http://localhost:3000
3. Test the feature as described
4. Test on mobile viewport (Chrome DevTools)
5. Test edge cases

### 7. Final Verification

Before completing:

- All tasks from plan completed
- All tests created and passing
- All validation commands pass
- Code follows project conventions
- Mobile responsive verified
- Documentation added/updated as needed

## Output Report

Provide summary:

### Completed Tasks
- List of all tasks completed
- Files created (with paths)
- Files modified (with paths)

### Tests Added
- Test files created
- Test cases implemented
- Test results (pass/fail)

### Validation Results

```bash
# Output from each validation command
```

### Screenshots/Evidence
- Describe what was manually tested
- Note any visual changes

### Issues Encountered
- Any deviations from the plan
- Problems solved during implementation
- Suggestions for plan improvements

### Ready for Commit
- Confirm all changes are complete
- Confirm all validations pass
- Ready for `/commit` command

## Update PROJECT-STATUS.md

After completing execution, update `PROJECT-STATUS.md`:

### Update Progress

```markdown
## Active Plan

**Plan:** `.agents/plans/[plan-name].md`
**Feature:** [Feature description]
**Phase:** Implementation Complete
**Progress:** [X/Y] tasks completed

### Completed Tasks
- [x] Task 1 - [Description]
- [x] Task 2 - [Description]
...
```

### Add to Recent Activity

```markdown
| [Today] | execute | Completed: [feature-name] |
```

### If All Tasks Complete

Update status to indicate ready for validation and commit:

```markdown
**Phase:** Implementation Complete
**Next Steps:**
1. Run `/validate` to verify all checks pass
2. Run `/commit` to create commit
```

## Notes

- If you encounter issues not addressed in the plan, document them
- If you need to deviate from the plan, explain why
- If tests fail, fix implementation until they pass
- Don't skip validation steps
- Ask for clarification if something is unclear
