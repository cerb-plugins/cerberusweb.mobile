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

	<h3 style="margin-bottom:0;">{$widget->label}</h3>
	
	<div style="margin-bottom:10px;">
		{$widget_extension->manifest->name}
	</div>

	<div id="widget{$widget->id}">
	{if $widget_extension instanceof Extension_WorkspaceWidget}
		{if $widget_extension->id == 'core.workspace.widget.worklist'}
			<div id="view{$view->id}">
			{include file="devblocks:cerberusweb.mobile::workspaces/worklist_view.tpl" view=$view}
			</div>
		{elseif $widget_extension->id == 'core.workspace.widget.calendar'}
			<div class="cerb-calendar">
			{include file="devblocks:cerberusweb.mobile::calendars/calendar.tpl"}
			</div>
		{else}
			{$widget_extension->render($widget)}
		{/if}
	{/if}
	</div>
</div>

</div><!-- /page -->

</body>
</html>