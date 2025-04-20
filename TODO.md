
- item availability check and update
- item rental rules
- order status vs event type vs deposit status vs dispute status vs order payment status




- item insurance options
- item maintenance record
- item history
- item bundle
- related items
- bulk import
- organization policy
- tenant settings



at which point du we set the deposit's status released or claimed?


ChatGPT said:
Great question — here’s a clean rule for when to update order_deposit.status to either RELEASED or CLAIMED, based on the action history:

✅ Decision Rules
Set status = RELEASED when:
The total released amount = full deposit

AND claimed amount = 0

💡 Means: no issues, deposit fully refunded

Set status = CLAIMED when:
Any amount is claimed (partial or full)

Regardless of whether anything was released

💡 Means: owner is keeping part or all of it

Keep status = HELD when:
No actions yet (initial state)

Or only partial releases or still pending decisions

✅ Optional: Automate it via SQL
If you're using Option A (no denormalized totals), you can create a SQL VIEW or materialized view that derives the current status like:


CASE
  WHEN SUM(CASE WHEN action_type = 'RELEASE' THEN amount ELSE 0 END) = d.amount
       AND NOT EXISTS (SELECT 1 FROM order_deposit_action WHERE order_deposit_id = d.id AND action_type = 'CLAIM')
    THEN 'RELEASED'
  WHEN EXISTS (SELECT 1 FROM order_deposit_action WHERE order_deposit_id = d.id AND action_type = 'CLAIM')
    THEN 'CLAIMED'
  ELSE 'HELD'
END AS computed_status
Let me know if you want a full SQL view snippet.