<!DOCTYPE html>
<html>

{include file="devblocks:cerberusweb.mobile::html_head.tpl"}

<body>

<div data-role="page" id="page-workspaces" data-theme="a" data-dom-cache="true">

{include file="devblocks:cerberusweb.mobile::header.tpl"}

<div data-role="content">

	<div class="choice_list">
		<h3>{$page_title|default:'Workspaces'}</h3>
		
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