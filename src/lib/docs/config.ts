import RocketIcon from '@lucide/svelte/icons/rocket';
import LayoutGridIcon from '@lucide/svelte/icons/layout-grid';
import ZapIcon from '@lucide/svelte/icons/zap';
import PaletteIcon from '@lucide/svelte/icons/palette';
import type { DocsConfig } from './types.js';

export const docsConfig: DocsConfig = {
	site: {
		title: 'LastMenu',
		description: 'Official documentation for LastMenu — universal menu system for FiveM.',
		url: 'https://kamion.github.io',
		social: {
			github: 'https://github.com/Kamion/LastMenu'
		}
	},
	sidebar: [
		{
			label: 'Introduction',
			icon: RocketIcon,
			autogenerate: { directory: 'introduction' }
		},
		{
			label: 'UI Components',
			icon: LayoutGridIcon,
			autogenerate: { directory: 'composants' }
		},
		{
			label: 'Advanced Features',
			icon: ZapIcon,
			autogenerate: { directory: 'avance' }
		},
		{
			label: 'Customization',
			icon: PaletteIcon,
			autogenerate: { directory: 'personnalisation' }
		}
	],
	toc: {
		minDepth: 2,
		maxDepth: 3
	},
	versions: {
		current: 'v1.0.0',
		versions: [
			{ label: 'v1.0.0 (latest)', href: '/docs' }
		]
	},
	i18n: {
		defaultLocale: 'en',
		locales: [
			{ code: 'en', label: 'English',  flag: '🇺🇸' },
			{ code: 'fr', label: 'Français', flag: '🇫🇷' },
			{ code: 'es', label: 'Español',  flag: '🇪🇸' },
			{ code: 'ru', label: 'Русский',  flag: '🇷🇺' },
			{ code: 'uk', label: 'Українська', flag: '🇺🇦' },
			{ code: 'ar', label: 'العربية',  flag: '🇸🇦' },
			{ code: 'zh', label: '中文',      flag: '🇨🇳' },
			{ code: 'de', label: 'Deutsch',  flag: '🇩🇪' },
			{ code: 'it', label: 'Italiano', flag: '🇮🇹' },
			{ code: 'pt', label: 'Português', flag: '🇵🇹' },
			{ code: 'ja', label: '日本語',    flag: '🇯🇵' },
			{ code: 'ko', label: '한국어',    flag: '🇰🇷' }
		]
	}
};
