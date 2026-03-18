export default {
	plugins: ["@trivago/prettier-plugin-sort-imports", "prettier-plugin-astro"],
	importOrder: ["^@/(.*)$", "^../", "^./"],
	importOrderCaseInsensitive: true,
	importOrderSeparation: true,
	importOrderSortSpecifiers: true,
	quoteProps: "consistent",
	semi: true,
	tabWidth: 4,
	useTabs: true,
	trailingComma: "none",
	overrides: [
		{
			files: "*.astro",
			options: {
				parser: "astro"
			}
		},
		{
			files: ["*.json", "*.md", "*.mdx", "*.toml", "*.yaml", "*.yml"],
			options: {
				tabWidth: 2,
				useTabs: false
			}
		}
	]
};
