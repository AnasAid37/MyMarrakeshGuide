import { expect, test } from "@playwright/test";

test("renders the public product promise", async ({ page }) => {
  await page.goto("/");
  await expect(page).toHaveTitle(/MyMarrakeshGuide/);
  await expect(page.getByRole("heading", { level: 1 })).toContainText("Marrakesh experience");
  await expect(page.getByText("Verified inventory only")).toBeVisible();
});

test("exposes a no-store health endpoint", async ({ request }) => {
  const response = await request.get("/api/health");
  expect(response.ok()).toBeTruthy();
  expect(response.headers()["cache-control"]).toContain("no-store");
  await expect(response.json()).resolves.toMatchObject({ status: "ok", service: "web" });
});
