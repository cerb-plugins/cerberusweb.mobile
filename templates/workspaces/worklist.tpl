<!DOCTYPE html>
<html>

{include file="devblocks:cerberusweb.mobile::html_head.tpl"}

<body>

<div data-role="page" id="page-workspace-widget" data-theme="c">

{include file="devblocks:cerberusweb.mobile::header.tpl"}

<div data-role="content">
	<div data-role="controlgroup" data-mini="true" data-type="horizontal" data-theme="a" style="margin:0px 0px 10px 0px;">
		<a href="{devblocks_url}c=m&p=workspaces{/devblocks_url}" data-role="button">Workspaces</a>
		<a href="{devblocks_url}c=m&p=workspace&id={$workspace_page->id}{/devblocks_url}" data-role="button">{$workspace_page->name}</a>
		<a href="{devblocks_url}c=m&p=workspace&a=tab&id={$workspace_tab->id}{/devblocks_url}" data-role="button">{$workspace_tab->name}</a>
	</div>
	
	<h3 style="margin-bottom:0;">{$view->name}</h3>
	
	<div style="margin-bottom:10px;">
		Worklist
	</div>

	<div id="view{$view->id}">
	{include file="devblocks:cerberusweb.mobile::workspaces/worklist_view.tpl" view=$view}
	</div>
</div>

{include file="devblocks:cerberusweb.mobile::footer.tpl"}

</div><!-- /page -->

</body>
</html>