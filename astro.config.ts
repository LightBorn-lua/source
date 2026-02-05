import starlight from '@astrojs/starlight'
import { defineConfig } from 'astro/config'
import starlightThemeGalaxy from 'starlight-theme-galaxy'


export default defineConfig({
  // site: 'https://localhost:4321/starlight-theme-galaxy',
  base: '/lightborn',
  integrations: [
    starlight({
      title: 'LightBorn',
      favicon: '/favicon.svg',
      // defaultLocale: 'en',
      // locales: {
      //   en: {
      //     label: 'English',
      //     lang: 'en',
      //   },  
      //   fr: {
      //     label: 'French',
      //     lang: 'fr',
      //   },
      // },
      editLink: {
        baseUrl: 'https://github.com/Error-Cezar/LightBorn/edit/docs/src/',
      },
      tableOfContents: {minHeadingLevel: 2, maxHeadingLevel: 4},
      plugins: [starlightThemeGalaxy()],
      sidebar: [
        {
          label: 'Start Here',
          items: ['getting-started', 'customization', 'components-override'],
        },
        { label: 'Examples', autogenerate: { directory: 'examples' } },
        { label: 'Custom Components', autogenerate: { directory: 'components' } },
      ],  
      social: [
        { href: 'https://github.com/Error-Cezar/LightBorn', icon: 'github', label: 'GitHub' },
      ],      
    }),
  ],
})
