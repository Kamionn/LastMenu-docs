<script lang="ts">
	import { onMount } from 'svelte';

	let { text, speed = 50 }: { text: string; speed?: number } = $props();

	let displayedText = $state('');
	let index = $state(0);

	onMount(() => {
		const interval = setInterval(() => {
			if (index < text.length) {
				displayedText += text[index];
				index++;
			} else {
				clearInterval(interval);
			}
		}, speed);

		return () => {
			clearInterval(interval);
		};
	});
</script>

<pre class="bg-background overflow-auto px-6 py-4 text-sm h-[28rem] min-h-[28rem]">
	<code class="text-foreground font-mono leading-relaxed whitespace-pre block">{displayedText}<span class="cursor">|</span></code>
</pre>

<style>
	.cursor {
		animation: blink 1s infinite;
		color: currentColor;
	}

	@keyframes blink {
		0%, 50% { opacity: 1; }
		51%, 100% { opacity: 0; }
	}
</style>