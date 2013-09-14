<!DOCTYPE html>
<html>

{include file="devblocks:cerberusweb.mobile::html_head.tpl"}

<body>

<div data-role="page" id="page-search" data-theme="c" data-dom-cache="true">

{include file="devblocks:cerberusweb.mobile::header.tpl"}

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