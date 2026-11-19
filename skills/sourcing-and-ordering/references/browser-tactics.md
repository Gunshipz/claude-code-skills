# Browser tactics for stores

Use plain web fetches for read-only checks when they work. Use a browser (Claude in
Chrome for stores they're signed in to, Playwright for a clean session) for carts and
checkout.

## The add-to-cart test (is it really in stock?)
Pick the size or option, then look at the buy button:
- It turns on (and a SKU appears) → in stock.
- It stays off or says "Notify me" → out of stock.
- If **everything** shows out of stock, suspect the site is blocking you, and check the
  item at a second store before reporting it gone.

## Cart and save checks: never trust the click
- "Add to cart" can silently do nothing. A hidden pop-up (warranty offers, upsells) can
  swallow the click. Proof is the cart count going up, or the item showing in the cart.
- Read the cart line: size, color and quantity. Mixed men's/women's size scales look
  identical until you read the cart.
- Saves can be two-step: the first button looks finished but nothing saved until a
  second confirm. Reload and read the value back.
- A button inside a hidden pop-up exists on the page but does nothing when clicked. Check
  it's visible (`offsetParent !== null`) first.

## Store APIs: faster and more honest than the page (Shopify especially)
Many stores have JSON endpoints. Use them to check price and stock, and to add exact
items to the cart. Use the page only for the checkout form.

**Shopify** (test by opening `/cart.js` on the store):
- `/products/<handle>.js` gives the true variants: `id`, `title`, `price` (in cents) and
  `available`. Trust this over the price shown on the page, which can be wrong.
- `/search/suggest.json?q=<term>&resources[type]=product&resources[limit]=5` finds the
  product handle.
- POST `/cart/add.js` with `{id: <variantId>, quantity: N}` adds the exact item. Then
  `/cart.js` confirms `item_count` and `total_price`. Run these with `fetch` inside the
  store tab so they use the live session.
- Read the variant title for shipping delays even when `available` is true.

Other platforms: WooCommerce has `/wp-json/wc/store/cart`, and BigCommerce has
`/api/storefront/carts`.

## Checkout walls
Amazon, Costco and many big stores have no guest checkout. A sign-in page for an account
the user owns is the hand-off point: they sign in, then you continue. Payment entry is
always where you stop.

## Pop-ups
Marketing pop-ups often sit in an iframe with an overlay that blocks every click until
closed. Find the iframe, then click its Close.

## When to stop and hand over
Stop on: "Just a moment" / bot checks that keep coming back, CAPTCHAs at submit,
"press and hold" challenges, or the session dying every time you click. Say so plainly,
give the user the exact link and what to click, and don't burn retries.
