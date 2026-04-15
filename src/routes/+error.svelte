<script lang="ts">
	import { page } from "$app/state";
	import { base } from '$app/paths';
	import { Button } from "$lib/components/ui/button/index.js";
</script>

<div class="bg-background flex min-h-screen flex-col items-center justify-center px-4 text-center">
	<p class="text-primary mb-2 text-sm font-semibold uppercase tracking-widest">
		{page.status}
	</p>
	<h1 class="text-foreground mb-4 text-4xl font-bold tracking-tight sm:text-5xl">
		{page.error?.message || "Something went wrong"}
	</h1>
	<p class="text-muted-foreground mb-8 max-w-md text-lg">
		The page you're looking for doesn't exist or an unexpected error occurred.
	</p>
	<div class="flex items-center gap-4">
		<Button href={base + '/'}>Go Home</Button>
		<Button variant="outline" href={base + '/docs'}>Browse Docs</Button>
	</div>
</div>
