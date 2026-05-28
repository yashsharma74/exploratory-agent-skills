# Viewports

Standardized browser viewport sizes for navigation sessions. Based on common screen resolutions in web analytics and industry testing breakpoints.

---

## Viewport Catalog

| ID | Name | Width | Height | Use case |
|---|---|---|---|---|
| `desktop` | Desktop | 1280 | 720 | Standard laptop screen — **default for all sessions** |
| `desktop-lg` | Large Desktop | 1920 | 1080 | Full HD monitor, wide layouts, admin dashboards |
| `tablet` | Tablet | 768 | 1024 | iPad portrait — tablet-specific layouts and touch targets |
| `mobile` | Mobile | 375 | 812 | iPhone-class device — mobile-responsive layouts |

---

## Selection Rules

- **Default:** `desktop` (1280×720) — used when the user does not specify.
- **Session-locked:** Once selected, the viewport is fixed for the session. Do not resize mid-session unless a viewport-switch step is explicitly part of the navigation instructions.
- **Responsive testing:** To test multiple viewports for the same task, run separate sessions — one per viewport. Each produces its own evidence and findings.

---

## Applying the Viewport

Always: `open` (no URL) → set viewport → `goto`.

### Headless (default)

```bash
playwright-cli open
playwright-cli resize {width} {height}
playwright-cli goto <TARGET_URL>
```

### Headed

```bash
playwright-cli open --headed
playwright-cli run-code "async page => {
  const cdp = await page.context().newCDPSession(page);
  const { windowId } = await cdp.send('Browser.getWindowForTarget');
  await cdp.send('Browser.setWindowBounds', {
    windowId,
    bounds: { width: {width}, height: {height}, windowState: 'normal' }
  });
  await page.setViewportSize({ width: {width}, height: {height} });
}"
playwright-cli goto <TARGET_URL>
```

Pass the same width and height to both `setWindowBounds` and `setViewportSize`.

### Audit log

```
[HH:MM:SS] [info] SESSION: viewport — desktop (1280×720)
```

---

## Why These Sizes

| ID | Rationale |
|---|---|
| `desktop` | 1280×720 is the most common laptop resolution worldwide. Captures the experience of the majority of desktop users without triggering wide-screen layouts. |
| `desktop-lg` | 1920×1080 is the dominant external monitor resolution. Tests whether wide layouts render correctly and sidebars/panels have enough space. |
| `tablet` | 768×1024 (iPad portrait) is the standard tablet breakpoint used by CSS frameworks (Bootstrap, Tailwind). Triggers tablet-specific responsive behavior. |
| `mobile` | 375×812 (iPhone X/11/12/13/14 logical resolution) is the most common mobile viewport. Triggers mobile navigation patterns (hamburger menus, stacked layouts). |
