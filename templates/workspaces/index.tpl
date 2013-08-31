<!DOCTYPE html>
<html>

{include file="devblocks:cerberusweb.mobile::html_head.tpl"}

<body>

<div data-role="page" id="page-workspaces" data-theme="c">

{include file="devblocks:cerberusweb.mobile::panel.tpl"}

<div data-theme="a" data-role="header" data-id="cerb-header" data-position="fixed">
	<h1>Cerb Mobile</h1>
	<a href="#cerb-panel" data-role="button" data-icon="bars" data-iconpos="notext" class="ui-btn-right">Menu</a>
</div>

<div data-role="content">

	<div class="choice_list">
		<h3>Workspaces</h3>
		
		<ul data-role="listview" data-inset="true" data-filter="true">
			{foreach from=$workspaces item=workspace key=workspace_id}
				{$context_ext = Extension_DevblocksContext::get($workspace->owner_context)}
				{$meta = $context_ext->getMeta($workspace->owner_context_id)}
			
				<li>
					<a href="{devblocks_url}c=m&a=workspace&id={$workspace_id}{/devblocks_url}" data-transition="slidedown">
						<h3>{$workspace->name}</h3>
						
						<p class="ui-li-desc">
							{$meta.name}
							({$context_ext->manifest->name}) 
						</p>
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