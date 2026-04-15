<script lang="ts">
	import { Button } from "$lib/components/ui/button/index.js";
	import { base } from '$app/paths';
	import DarkModeSwitcher from "$lib/components/theme/dark-mode-switcher.svelte";
	import ArrowRightIcon from "@lucide/svelte/icons/arrow-right";
	import GithubIcon from "@lucide/svelte/icons/github";
	import ZapIcon from "@lucide/svelte/icons/zap";
	import LayoutGridIcon from "@lucide/svelte/icons/layout-grid";
	import PaletteIcon from "@lucide/svelte/icons/palette";
	import ShieldIcon from "@lucide/svelte/icons/shield";
	import RefreshCwIcon from "@lucide/svelte/icons/refresh-cw";
	import LayersIcon from "@lucide/svelte/icons/layers";
	import MonitorIcon from "@lucide/svelte/icons/monitor";
	import PackageIcon from "@lucide/svelte/icons/package";
	import Typewriter from "$lib/components/Typewriter.svelte";

	const features = [
		{
			icon: LayoutGridIcon,
			title: "7 Components, 1 API",
			description: "Context Menu, Radial Menu, Target Menu, and more",
		},
		{
			icon: LayersIcon,
			title: "Zero dependencies",
			description: "Works without ox_lib, qbx_core or any framework. Install and it runs.",
		},
		{
			icon: ZapIcon,
			title: "Unified API",
			description: "One builder pattern for all menu types — context, radial, input, alert, notify, progress, target.",
		},
		{
			icon: RefreshCwIcon,
			title: "Real-time reactivity",
			description: "Integrated polling diff/patch engine. Labels, visible and disabled update without closing the menu.",
		},
		{
			icon: ShieldIcon,
			title: "Safe Mode",
			description: "Defective watchers are automatically disabled and recovered — no cascade crashes.",
		},

		{
			icon: PaletteIcon,
			title: "CSS theming",
			description: "100% CSS custom properties. Override only the variables you want to change.",
		},
		{
			icon: MonitorIcon,
			title: "Pre-compiled Svelte 5 UI",
			description: "No npm install required on the game server side. The UI is already in ui/assets/.",
		},
		{
			icon: PackageIcon,
			title: "Native FiveM",
			description: "Standard Lua exports, client-side callbacks, NUI bridge with high-frequency batching.",
		},
	];

	const docsPath = (path: string) => `${base}${path}`;

	const components = [
		{ name: "Context Menu", desc: "Rich vertical menu — all item types supported", href: docsPath('/docs/composants/context-menu') },
		{ name: "Radial Menu", desc: "Quick action wheel — mouse, keyboard, controller", href: docsPath('/docs/composants/radial') },
		{ name: "Input Form", desc: "Modal multi-field form with validation", href: docsPath('/docs/composants/input') },
		{ name: "Modal / Alert", desc: "Blocking confirmation — callback or async style", href: docsPath('/docs/composants/modal') },
		{ name: "Notifications", desc: "Non-blocking toasts with group deduplication", href: docsPath('/docs/composants/notifications') },
		{ name: "Progress Bar", desc: "Bar with ped, prop and cb_tick animation", href: docsPath('/docs/composants/progress') },
		{ name: "Target System", desc: "ox_target replacement — entities, zones, polygons", href: docsPath('/docs/composants/target') },
	];

	const fullCode = `
	local UI = exports['LastMenu']

	function TriggerGarageMenu()
		UI:context(function(menu)
			menu:title("Garage")
			menu:description("Vehicle maintenance")
			menu:banner("https://example.com/garage.gif")
			menu:button("Repair engine", {
				icon = "wrench",
				badge = "500 €",
				confirm_hold = true,
				cb = function() RepairFunction() end,
			})
		end)
	end`;
</script>

<!-- Navbar -->
<nav class="bg-background/80 sticky top-0 z-50 border-b backdrop-blur-md">
	<div class="mx-auto flex h-14 max-w-7xl items-center justify-between px-4 sm:px-6 lg:px-8">
		<div class="flex items-center gap-2">
			<LayersIcon class="text-primary size-5" />
			<span class="text-lg font-bold tracking-tight">LastMenu</span>
		</div>
		<div class="hidden items-center gap-6 md:flex">
			<a href="/" class="text-foreground text-sm font-medium">Home</a>
			<a href={docsPath('/docs')} class="text-muted-foreground hover:text-foreground text-sm">Documentation</a>
			<a href={docsPath('/docs/introduction/installation')} class="text-muted-foreground hover:text-foreground text-sm">Installation</a>
		</div>
		<div class="flex items-center gap-2">
			<DarkModeSwitcher />
			<Button variant="ghost" size="icon" href="https://github.com/Kamionn/LastMenu" target="_blank" aria-label="GitHub">
				<GithubIcon class="size-4" />
			</Button>
		</div>
	</div>
</nav>

<!-- Hero Section -->
<section class="relative overflow-hidden">
	<div class="from-primary/5 via-background to-background absolute inset-0 bg-linear-to-b"></div>
	<div class="from-primary/10 to-primary/0 absolute left-1/2 top-0 hidden size-[800px] -translate-x-1/2 -translate-y-1/2 rounded-full bg-linear-to-b blur-3xl sm:block"></div>
	<div class="relative mx-auto max-w-7xl px-4 py-20 sm:px-6 sm:py-28 lg:py-32">
		<div class="grid gap-10 lg:grid-cols-[1.1fr_0.9fr] items-start">
			<div class="text-center lg:text-left">
				<div class="bg-muted text-muted-foreground mb-6 inline-flex items-center gap-2 rounded-full px-4 py-1.5 text-sm">
					<ZapIcon class="size-3.5" />
					<span>v1.0.0 — Zero dependencies · Svelte 5 · FiveM</span>
				</div>
				<h1 class="text-foreground mb-6 text-5xl font-bold tracking-tight sm:text-6xl lg:text-7xl">
					LastMenu
				</h1>
				<p class="text-muted-foreground mb-6 max-w-2xl text-xl font-medium sm:text-2xl">
					Universal menu system for FiveM.
				</p>
				<p class="text-muted-foreground mb-10 max-w-2xl text-base sm:text-lg leading-8">
					One API. All menu types. Real-time reactivity.
					Works without <code class="bg-muted rounded px-1.5 py-0.5 text-sm">ox_lib</code>,
					<code class="bg-muted rounded px-1.5 py-0.5 text-sm">qbx_core</code> or any framework.
				</p>
				<div class="flex flex-col items-center justify-center gap-4 sm:flex-row lg:justify-start">
					<Button size="lg" href={docsPath('/docs/introduction/installation')} class="gap-2 px-8 text-base">
						Start integration
						<ArrowRightIcon class="size-4" />
					</Button>
					<Button variant="outline" size="lg" href="https://github.com/Kamionn/LastMenu" target="_blank" class="gap-2 px-6">
						<GithubIcon class="size-4" />
						GitHub
					</Button>
				</div>
			</div>

			

				<div class="overflow-hidden rounded-[1.5rem] border border-white/10 bg-background/95">
					<div class="bg-muted/50 border-b px-4 py-2 flex items-center gap-2">
						<div class="size-3 rounded-full bg-red-400/60"></div>
						<div class="size-3 rounded-full bg-yellow-400/60"></div>
						<div class="size-3 rounded-full bg-green-400/60"></div>
						<span class="text-muted-foreground ml-2 text-xs font-mono">client/garage.lua</span>
					</div>
					<Typewriter text={fullCode} />
				
			</div>
		</div>
	</div>
</section>

<!-- Features Section -->
<section class="border-t py-20 sm:py-28">
	<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
		<div class="mb-14 text-center">
			<h2 class="text-foreground mb-4 text-3xl font-bold tracking-tight sm:text-4xl">
				Designed to eliminate friction
			</h2>
			<p class="text-muted-foreground mx-auto max-w-2xl text-lg">
				Everything you need, without the dependencies you don't want.
			</p>
		</div>
		<div class="grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
			{#each features as feature}
				<div class="group rounded-xl border p-6 transition-all hover:shadow-lg hover:border-primary/20">
					<div class="bg-primary/10 text-primary mb-4 flex size-12 items-center justify-center rounded-lg">
						<feature.icon class="size-6" />
					</div>
					<h3 class="text-foreground mb-2 text-base font-semibold">{feature.title}</h3>
					<p class="text-muted-foreground text-sm leading-relaxed">{feature.description}</p>
				</div>
			{/each}
		</div>
	</div>
</section>

<!-- Footer -->
<footer class="border-t py-12 sm:py-16">
	<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
		<div class="grid gap-8 sm:grid-cols-2 lg:grid-cols-4">
			<div>
				<h4 class="text-foreground mb-4 text-sm font-semibold">Introduction</h4>
				<ul class="space-y-3">
					<li><a href={docsPath('/docs/introduction/installation')} class="text-muted-foreground hover:text-foreground text-sm">Installation</a></li>
					<li><a href={docsPath('/docs/introduction/quickstart')} class="text-muted-foreground hover:text-foreground text-sm">Quick Start</a></li>
				</ul>
			</div>
			<div>
				<h4 class="text-foreground mb-4 text-sm font-semibold">Components</h4>
				<ul class="space-y-3">
					<li><a href={docsPath('/docs/composants/context-menu')} class="text-muted-foreground hover:text-foreground text-sm">Context Menu</a></li>
					<li><a href={docsPath('/docs/composants/radial')} class="text-muted-foreground hover:text-foreground text-sm">Radial Menu</a></li>
					<li><a href={docsPath('/docs/composants/target')} class="text-muted-foreground hover:text-foreground text-sm">Target System</a></li>
					<li><a href={docsPath('/docs/composants/notifications')} class="text-muted-foreground hover:text-foreground text-sm">Notifications</a></li>
				</ul>
			</div>
			<div>
				<h4 class="text-foreground mb-4 text-sm font-semibold">Advanced</h4>
				<ul class="space-y-3">
					<li><a href={docsPath('/docs/avance/reactivite')} class="text-muted-foreground hover:text-foreground text-sm">Reactivity</a></li>
					<li><a href={docsPath('/docs/avance/async-api')} class="text-muted-foreground hover:text-foreground text-sm">Async API</a></li>
					<li><a href={docsPath('/docs/avance/sous-menus')} class="text-muted-foreground hover:text-foreground text-sm">Sub-menus</a></li>
					<li><a href={docsPath('/docs/personnalisation/theming')} class="text-muted-foreground hover:text-foreground text-sm">Theming</a></li>
				</ul>
			</div>
			<div>
				<h4 class="text-foreground mb-4 text-sm font-semibold">Project</h4>
				<ul class="space-y-3">
					<li>
						<a href="https://github.com/Kamionn/LastMenu" target="_blank" rel="noopener noreferrer" class="text-muted-foreground hover:text-foreground inline-flex items-center gap-1.5 text-sm">
							<GithubIcon class="size-3.5" /> GitHub
						</a>
					</li>
					<li><a href={docsPath('/docs/personnalisation/migration')} class="text-muted-foreground hover:text-foreground text-sm">Migration Guide</a></li>
					<li><a href={docsPath('/docs/personnalisation/pitfalls')} class="text-muted-foreground hover:text-foreground text-sm">Common Pitfalls</a></li>
					<li><a href={docsPath('/docs/personnalisation/debugging')} class="text-muted-foreground hover:text-foreground text-sm">Debugging</a></li>
				</ul>
			</div>
		</div>
		<div class="text-muted-foreground mt-12 border-t pt-8 text-center text-sm">
			LastMenu · Licence MIT ·
			<a href="https://github.com/Kamionn" target="_blank" rel="noopener noreferrer" class="text-foreground hover:underline">Kamion</a>
		</div>
	</div>
</footer>
