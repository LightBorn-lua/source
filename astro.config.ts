import starlight from "@astrojs/starlight";
import { defineConfig } from "astro/config";
import starlightThemeGalaxy from "starlight-theme-galaxy";

export default defineConfig({
  base: "/LightBorn",
  integrations: [
    starlight({
      title: "LightBorn",
      favicon: "/favicon.svg",
      editLink: {
        baseUrl: "https://github.com/LightBorn-lua/LightBorn/edit/docs/src/",
      },
      tableOfContents: { minHeadingLevel: 2, maxHeadingLevel: 4 },
      plugins: [starlightThemeGalaxy()],
      sidebar: [
        {
          label: "Start Here",
          items: ["getting-started", "first-system", "configuration"],
        },
        { label: "API Reference", autogenerate: { directory: "api-reference" } },
      ],
      social: [
        {
          href: "https://github.com/LightBorn-lua/LightBorn",
          icon: "github",
          label: "GitHub",
        },
      ],
    }),
  ],
});
