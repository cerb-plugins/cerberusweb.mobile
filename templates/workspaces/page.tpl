<!DOCTYPE html>
<html>

{include file="devblocks:cerberusweb.mobile::html_head.tpl"}

<body>

<div data-role="page" id="page-workspace" data-theme="c">

<div data-theme="a" data-role="header" data-id="cerb-header" data-position="fixed">
	<a href="{devblocks_url}c=m&a=workspaces{/devblocks_url}" data-role="button" data-icon="arrow-l" data-iconpos="left" class="ui-btn-left">Workspaces</a>
	<h1>Cerb Mobile</h1>
</div>

<div data-role="content">

	<div class="choice_list">
		<h3>{$workspace->name}</h3>
		
		<ul data-role="listview" data-inset="true" data-filter="true">
			{foreach from=$workspace_tabs item=workspace_tab key=workspace_tab_id}
			<li>
				<a href="{devblocks_url}c=m&a=workspace&w=tab&id={$workspace_tab_id}{/devblocks_url}" data-transition="slidedown">
					<h3 class="ui-li-heading">{$workspace_tab->name}</h3>
					{$workspace_tab_ext = Extension_WorkspaceTab::get($workspace_tab->extension_id)}
					<p class="ui-li-desc">{$workspace_tab_ext->manifest->params.label|devblocks_translate|capitalize}</p>
				</a>
			</li>
			{/foreach}
		</ul>
	</div>

</div>

{include file="devblocks:cerberusweb.mobile::footer.tpl"}

</div><!-- /page -->

</body>
</html>