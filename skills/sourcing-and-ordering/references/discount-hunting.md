# Discount hunting: run before every checkout

Work down the list and stop when the savings stop growing.

1. **Banners on the site.** Product and checkout pages often show a first-order code in the
   top banner. Read it before closing it.
2. **Newsletter popup.** Usually the only real code a small brand has (often 10–15%). It
   shows once per visitor. To bring it back, run this in the store tab, then wait ~5 s:

   ```js
   () => {
     try { localStorage.clear(); sessionStorage.clear(); } catch (e) {}
     document.cookie.split(';').forEach(c => {
       const n = c.split('=')[0].trim();
       document.cookie = n + '=;expires=Thu, 01 Jan 1970 00:00:00 GMT;path=/';
       document.cookie = n + '=;expires=Thu, 01 Jan 1970 00:00:00 GMT;path=/;domain=.' + location.hostname.replace(/^www\./, '');
     });
     location.reload();
   }
   ```
   Sign up with **the user's own email**, and only with their OK, because it means
   marketing mail. If a popup exists, its form is the one tied to the code; footer
   sign-ups often join a list with no code. If no popup ever appears, read the footer
   form's promise. It may be the code channel.
3. **Get the code.** If their email is connected, search it (`from:<store domain>`). Codes
   can take 5–15 minutes to arrive.
4. **Coupon sites, as a sanity check only.** They mostly recycle the newsletter code.
   Check that the code is for the same store (look-alike names exist).
5. **Cashback** (Rakuten, TopCashback) stacks with codes. Mention it; don't require it.
6. **Timing.** If it isn't urgent, mention the next big sale window.

**Big stores (Amazon, Walmart, Costco, Target):** steps 1–3 usually don't apply. Say so
instead of hunting. What does apply: price history, card-linked offers, subscribe-and-save,
member pricing, open-box and refurbished.

Report it as list price → code → net, with cashback as an extra. A code counts only once
the cart total actually drops. "No discounts available" is a complete answer.
