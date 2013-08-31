<div id="view{$view->id}">

{$data = $view->getData()}
{$results = $data.0}
{$total = $data.1}

{$context_ext = Extension_DevblocksContext::getByViewClass(get_class($view), true)}

<div class="choice_list">

	<ul data-role="listview" data-inset="true" data-icon="false" data-filter="false">
		
	{foreach from=$results item=result key=result_id}
		{CerberusContexts::getContext($context_ext->id, $result_id, $labels, $values, null, true)}
		{$dict = DevblocksDictionaryDelegate::instance($values)}
	
		<li>
			<a href="{devblocks_url}c=m&w=profile&context={$context_ext->id}&context_id={$result_id}{/devblocks_url}" data-transition="slide">
				{if isset($dict->updated)}{$updated = $dict->updated}{elseif isset($dict->updated_date)}{$updated = $dict->updated_date}{/if}
				{if $updated}<p class="ui-li-aside ui-li-desc">{$updated|devblocks_prettytime}</p>{/if}
				<h3 class="ui-li-heading">{$dict->_label}</h3>
			</a>
		</li>
		
	{foreachelse}
		<li>
			This worklist is empty.
		</li>
	
	{/foreach}
	
	</ul>
	
</div>

</div>
