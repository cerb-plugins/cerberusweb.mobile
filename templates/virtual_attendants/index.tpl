<!DOCTYPE html>
<html>

{include file="devblocks:cerberusweb.mobile::html_head.tpl"}

<body>

<div data-role="page" id="page-va" data-theme="c">

<div data-theme="a" data-role="header" data-id="cerb-header" data-position="fixed">
	<h1>Cerb Mobile</h1>
</div>

<div data-role="content">

	<div class="choice_list">
		<h3>Virtual Attendants</h3>
		
		<ul data-role="listview" data-inset="true" data-filter="true">
			{foreach from=$vas item=va key=va_id}
				{$context_ext = Extension_DevblocksContext::get($va->owner_context)}
				{$meta = $context_ext->getMeta($va->owner_context_id)}
			
				<li>
					<a href="{devblocks_url}c=m&a=va&id={$va_id}{/devblocks_url}" data-transition="slidedown">
						<h3 class="ui-li-heading">
							{$va->name}
						</h3>
						
						<p class="ui-li-desc">
							{$meta.name}
							({$context_ext->manifest->name}) 
						</p>
					</a>
				</li>
			{foreachelse}
				<li>
					There are no Virtual Attendants with mobile behaviors.
				</li>
			{/foreach}
		</ul>
	</div>

</div>

{include file="devblocks:cerberusweb.mobile::footer.tpl"}

</div><!-- /page -->

</body>
</html>