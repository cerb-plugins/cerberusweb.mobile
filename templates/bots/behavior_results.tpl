<!DOCTYPE html>
<html>

{include file="devblocks:cerberusweb.mobile::html_head.tpl"}

<body>

<div data-role="page" id="page-va-behavior-results{$behavior->id}" data-theme="a" class="cerb-page-va-behavior-results" data-dom-cache="true">

{include file="devblocks:cerberusweb.mobile::header.tpl"}

<div data-role="content">
	<div data-role="controlgroup" data-mini="true" data-type="horizontal" data-theme="a" style="margin:0px 0px 10px 0px;">
		<a href="{devblocks_url}c=m&p=va{/devblocks_url}" data-role="button">Attendants</a>
		<a href="{devblocks_url}c=m&p=va&id={$va->id}{/devblocks_url}" data-role="button">{$va->name}</a>
		<a href="{devblocks_url}c=m&p=va&m=behavior&id={$behavior->id}{/devblocks_url}" data-role="button">{$behavior->title}</a>
	</div>

	<b>{$va->name}</b> said:
	
	{foreach from=$responses item=response}
	<div style="margin-top:10px;">
	
		{if $response.type == 'html'}
		
			<div class="cerb-va-message">
			{$response.message nofilter}
			</div>
		
		{elseif $response.type == 'worklist'}
		
			{$view = C4_AbstractViewLoader::getView($response.view_id)}
			<div id="view{$view->id}">
			{include file="devblocks:cerberusweb.mobile::workspaces/worklist_view.tpl" view=$view}
			</div>
		
		{else}
		
			<div class="cerb-va-message" style="border-radius:5px;padding:10px;background-color:rgb(240,240,240);">
			{$response.message|escape:'htmlall'|devblocks_hyperlinks|nl2br nofilter}
			</div>
		
		{/if}
	</div>
	
	{/foreach}

</div>

</script>

</div><!-- /page -->

</body>
</html>
