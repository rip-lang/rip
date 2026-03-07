// @ts-check
import starlight from "@astrojs/starlight";
import { defineConfig } from "astro/config";

// https://astro.build/config
export default defineConfig({
	integrations: [
		starlight({
			title: "Rip Docs",
			social: [
				{
					icon: "github",
					label: "GitHub",
					href: "https://github.com/withastro/starlight"
				}
			],
			sidebar: [
				{
					label: "Introduction",
					autogenerate: { directory: "introduction" }
				},
				{
					label: "Syntax",
					items: [
						{ slug: "syntax/comments" },
						{
							label: "Literals",
							collapsed: true,
							autogenerate: { directory: "syntax/literals" }
						},
						{
							label: "Control Flow",
							collapsed: true,
							autogenerate: { directory: "syntax/control-flow" }
						},
						{ slug: "syntax/assignments" },
						{ slug: "syntax/functions" },
						{ slug: "syntax/modules" },
						{ slug: "syntax/structures" },
						{ slug: "syntax/types" }
					]
				},
				{
					label: "Semantics",
					autogenerate: { directory: "semantics" }
				},
				{
					label: "Internals",
					collapsed: true,
					items: [
						{
							label: "Decisions",
							collapsed: true,
							autogenerate: { directory: "internals/decisions" }
						}
					]
				}
			]
		})
	]
});
