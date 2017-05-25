<!DOCTYPE html>
<html>

{include file="devblocks:cerberusweb.mobile::html_head.tpl"}

<body>

<div data-role="page" id="page-bots" data-theme="a" data-dom-cache="true">

{include file="devblocks:cerberusweb.mobile::header.tpl"}

<div data-role="content">

	<div class="choice_list">
		<h3>{'common.bots'|devblocks_translate|capitalize}</h3>
		
		<ul data-role="listview" data-inset="true" data-filter="true">
			{foreach from=$interactions_menu item=bot key=bot_id}
			<li data-role="list-divider">
				{$bot->label}
				
				{foreach from=$bot->children item=interaction}
				<li>
					<a href="{devblocks_url}c=m&a=bots&id={$bot_id}&behavior_id={$interaction->key}{/devblocks_url}?interaction={$interaction->interaction|escape}{foreach from=$interaction->params item=param_value key=param_key}&interaction_param[{$param_key|escape}]={$param_value|escape}{/foreach}" data-ajax="false">
						<img src="{$bot->image}">
						{$interaction->label}
					</a>
				</li>
				{/foreach}
			</li>
			{foreachelse}
				<li>There aren't any conversational bots with mobile interactions.</li>
			{/foreach}
		</ul>
		
		{*
		<ul data-role="listview" data-inset="true" data-filter="true">
			{foreach from=$bots item=bot key=bot_id}
				{$context_ext = Extension_DevblocksContext::get($bot->owner_context)}
				{$meta = $context_ext->getMeta($bot->owner_context_id)}
			
				<li>
					<a href="{devblocks_url}c=m&a=bots&id={$bot_id}{/devblocks_url}" data-transition="fade">
				</li>
			{/foreach}
		</ul>
		*}
	</div>

</div>

{include file="devblocks:cerberusweb.mobile::footer.tpl"}

</div><!-- /page -->

</body>
</html>