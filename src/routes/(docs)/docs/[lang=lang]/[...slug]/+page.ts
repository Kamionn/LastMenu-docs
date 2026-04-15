import { docsConfig, getDoc, getAllDocs, getPrevNext } from '$lib/docs/index.js';
import { error } from '@sveltejs/kit';
import type { PageLoad } from './$types.js';

export const prerender = true;
export const entries = () => {
	const locales = docsConfig.i18n?.locales ?? [];
	const defaultLocale = docsConfig.i18n?.defaultLocale ?? 'en';
	const results: { lang: string; slug: string }[] = [];

	for (const locale of locales) {
		if (locale.code === defaultLocale) continue;
		const docs = getAllDocs(locale.code);
		for (const doc of docs) {
			if (doc.slug) {
				results.push({ lang: locale.code, slug: doc.slug });
			}
		}
	}

	return results;
};

export const load: PageLoad = ({ params }) => {
	const slug = params.slug.replace(/\/$/, '');
	const doc = getDoc(slug, params.lang);
	if (!doc) throw error(404, `Page not found: ${slug}`);

	const { prev, next } = getPrevNext(slug, params.lang);

	return {
		meta: doc.meta,
		slug,
		locale: params.lang,
		prev,
		next
	};
};
