<!DOCTYPE html>
<html>

{include file="devblocks:cerberusweb.mobile::html_head.tpl"}

<body>

<div data-role="page" id="page-va" data-theme="a" data-dom-cache="true">

{include file="devblocks:cerberusweb.mobile::header.tpl"}

<div data-role="content">

	<div class="choice_list">
		<h3>{'common.bots'|devblocks_translate|capitalize}</h3>
		
		<ul data-role="listview" data-inset="true" data-filter="true">
			{foreach from=$vas item=va key=va_id}
				{$context_ext = Extension_DevblocksContext::get($va->owner_context)}
				{$meta = $context_ext->getMeta($va->owner_context_id)}
			
				<li>
					<a href="{devblocks_url}c=m&a=va&id={$va_id}{/devblocks_url}" data-transition="fade">
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
					There are no bots with mobile behaviors.
				</li>
			{/foreach}
		</ul>
	</div>

</div>

{include file="devblocks:cerberusweb.mobile::footer.tpl"}

</div><!-- /page -->

</body>
</html>