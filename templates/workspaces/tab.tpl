<!DOCTYPE html>
<html>

{include file="devblocks:cerberusweb.mobile::html_head.tpl"}

<body>

<div data-role="page" id="page-workspace-tab" data-theme="a" data-dom-cache="true">

{include file="devblocks:cerberusweb.mobile::header.tpl"}

<div data-role="content">

	<div class="choice_list">
		<div data-role="controlgroup" data-mini="true" data-type="horizontal" data-theme="a" style="margin:0px 0px 10px 0px;">
			<a href="{devblocks_url}c=m&p=workspaces{/devblocks_url}" data-role="button">Workspaces</a>
			<a href="{devblocks_url}c=m&p=workspace&id={$workspace_page->id}{/devblocks_url}" data-role="button">{$workspace_page->name}</a>
		</div>
	
		<h3 style="margin-bottom:0px;">{$workspace_tab->name}</h3>
		<div style="margin-bottom:20px;">
			{$workspace_tab_ext = Extension_WorkspaceTab::get($workspace_tab->extension_id)}
			{$workspace_tab_ext->manifest->params.label|devblocks_translate}
		</div>
		
		{if $workspace_tab->extension_id == 'core.workspace.tab.worklists' && !empty($workspace_lists)}
		<ul data-role="listview" data-inset="true" data-filter="true">
			{foreach from=$workspace_lists item=workspace_list key=workspace_list_id}
			<li>
				<a href="{devblocks_url}c=m&a=workspace&w=worklist&id={$workspace_list_id}{/devblocks_url}" data-transition="slidedown">
					<h3 class="ui-li-heading">{$workspace_list->name}</h3>
					<p class="ui-li-desc">Worklist</p>
				</a>
			</li>
			{/foreach}
		</ul>
		{/if}
		
		{if $workspace_tab->extension_id == 'core.workspace.tab.dashboard' && !empty($workspace_widgets)}
		<ul data-role="listview" data-inset="true" data-filter="true">
			{foreach from=$workspace_widgets item=workspace_widget key=workspace_widget_id}
			<li>
				<a href="{devblocks_url}c=m&a=workspace&w=widget&id={$workspace_widget_id}{/devblocks_url}" data-transition="slidedown">
					<h3 class="ui-li-heading">{$workspace_widget->label}</h3>
					{$workspace_widget_ext = Extension_WorkspaceWidget::get($workspace_widget->extension_id)}
					<p class="ui-li-desc">{$workspace_widget_ext->manifest->name}</p>
				</a>
			</li>
			{/foreach}
		</ul>
		{/if}
		
		{if $workspace_tab->extension_id == 'core.workspace.tab.calendar' && isset($dict)}
			<div class="cerb-calendar">
			{include file="devblocks:cerberusweb.mobile::calendars/calendar.tpl"}
			</div>
		{/if}
	</div>

</div>

{include file="devblocks:cerberusweb.mobile::footer.tpl"}

</div><!-- /page -->

</body>
</html>