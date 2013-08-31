<!DOCTYPE html>
<html>

{include file="devblocks:cerberusweb.mobile::html_head.tpl"}

<body>

<div data-role="page" id="page-workspace-widget" data-theme="c">

{include file="devblocks:cerberusweb.mobile::panel.tpl"}

<div data-theme="a" data-role="header" data-id="cerb-header" data-position="fixed">
	<a data-role="button" data-direction="reverse" data-rel="back" data-icon="arrow-l" data-iconpos="left" class="ui-btn-left">Back</a>
	<h1>Cerb Mobile</h1>
	<a href="#cerb-panel" data-role="button" data-icon="bars" data-iconpos="notext" class="ui-btn-right">Menu</a>
</div>

<div data-role="content">
	<a href="{devblocks_url}c=m&p=workspace&id={$workspace_page->id}{/devblocks_url}" data-role="button">{$workspace_page->name}</a>
	<a href="{devblocks_url}c=m&p=workspace&a=tab&id={$workspace_tab->id}{/devblocks_url}" data-role="button">{$workspace_tab->name}</a>

	<h3 style="margin-bottom:0;">{$view->name}</h3>
	
	<div style="margin-bottom:10px;">
		Worklist
	</div>

	{include file="devblocks:cerberusweb.mobile::workspaces/worklist_view.tpl" view=$view}
</div>

{include file="devblocks:cerberusweb.mobile::footer.tpl"}

</div><!-- /page -->

</body>
</html>