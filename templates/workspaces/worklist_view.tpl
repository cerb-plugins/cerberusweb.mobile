<div id="view{$view->id}">

{$data = $view->getData()}
{$results = $data.0}
{$total = $data.1}

{$context_ext = Extension_DevblocksContext::getByViewClass(get_class($view), true)}

<div class="choice_list">

	<ul data-role="listview" data-inset="true" data-filter="false">
		
	{foreach from=$results item=result key=result_id}
		{$meta = $context_ext->getMeta($result_id)}
	
		{* CerberusContexts::getContext($context_ext->id, $result_id, $labels, $values, null, true) *}
		{* $dict = DevblocksDictionaryDelegate::instance($values) *}
	
		<li>
			<a href="{$meta.permalink}" data-transition="slideright" target="_blank">
				<h3 class="ui-li-heading">{$meta.name}</h3>
				{*<p class="ui-li-desc">({$workspace_tab->extension_id})</p>*}
			</a>
		</li>
	{/foreach}
	
	</ul>
	
</div>

</div>
