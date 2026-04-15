import { getAllDocs, getDoc, getPrevNext, getRawContent } from '$lib/docs/index.js';
import { error } from '@sveltejs/kit';
import type { PageLoad } from './$types.js';

export const prerender = true;
export const entries = () => getAllDocs().map((doc) => ({ slug: doc.slug }));

export const load: PageLoad = ({ params }) => {
	const slug = params.slug.replace(/\/$/, '');
	const doc = getDoc(slug);
	if (!doc) throw error(404, `Page not found: ${slug}`);

	const { prev, next } = getPrevNext(slug);

	return {
		meta: doc.meta,
		slug,
		prev,
		next,
		rawContent: getRawContent(slug)
	};
};
