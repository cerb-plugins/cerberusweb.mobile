<!DOCTYPE html>
<html>

{include file="devblocks:cerberusweb.mobile::html_head.tpl"}

<body>

<div data-role="page" id="page-search-context" data-theme="c">

{include file="devblocks:cerberusweb.mobile::header.tpl"}

<div data-role="content">
	<div data-role="controlgroup" data-mini="true" data-type="horizontal" data-theme="a" style="margin:0px 0px 10px 0px;">
		<a href="{devblocks_url}c=m&p=search{/devblocks_url}" data-role="button">Search</a>
	</div>

	<h3 style="margin-bottom:0;">{$context_ext->manifest->name}</h3>
	
	<div style="margin-bottom:10px;">
		{$view->name}
	</div>

	<div id="view{$view->id}">
	{include file="devblocks:cerberusweb.mobile::workspaces/worklist_view.tpl" view=$view}
	</div>
</div>

{include file="devblocks:cerberusweb.mobile::footer.tpl"}

</div><!-- /page -->

</body>
</html>