<!DOCTYPE html>
<html>

{include file="devblocks:cerberusweb.mobile::html_head.tpl"}

<body>

<div data-role="page" id="page-search" data-theme="c">

{include file="devblocks:cerberusweb.mobile::panel.tpl"}

<div data-theme="a" data-role="header" data-id="cerb-header" data-position="fixed">
	<h1>Cerb Mobile</h1>
	<a href="#cerb-panel" data-role="button" data-icon="bars" data-iconpos="notext" class="ui-btn-right">Menu</a>
</div>

<div data-role="content">

	<div class="choice_list">
		<h3>Search</h3>
		
		<ul data-role="listview" data-inset="true" data-filter="true">
			{foreach from=$contexts item=context_ext key=context_ext_id}
				<li>
					<a href="{devblocks_url}c=m&a=search&ctx={$context_ext_id}{/devblocks_url}" data-transition="slide">
						<h3>{$context_ext->name}</h3>
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