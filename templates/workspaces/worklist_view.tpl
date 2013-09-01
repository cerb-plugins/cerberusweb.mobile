{$data = $view->getData()}
{$results = $data.0}
{$total = $data.1}

{$context_ext = Extension_DevblocksContext::getByViewClass(get_class($view), true)}

{$fields = $view->getFields()}
{$params = $view->getEditableParams()}
{$presets = $view->getPresets()}

<div id="viewFiltersPopup" data-role="popup" class="ui-content" data-theme="b" data-overlay-theme="a" data-transition="slidedown">
	{capture "options"}
	{foreach from=$view->getParamsAvailable() item=field key=token}
	{if !empty($field->db_label) && (!empty($field->type) || ($view instanceof IAbstractView_QuickSearch && $view->isQuickSearchField($token)))}
	<option value="{$token}" {if $pref_token==$token}selected="selected"{/if} field_type="{$field->type}">{$field->db_label|capitalize}</option>
	{/if}
	{/foreach}
	{/capture}

	<h3 style="margin:0;padding:0;">{'common.filter'|devblocks_translate|capitalize}</h3>
	
	{if $smarty.capture.options}
	<form action="{$response_path}" method="post" data-ajax="false">
		<input type="hidden" name="c" value="m">
		<input type="hidden" name="a" value="viewQuickSearch">
		<input type="hidden" name="view_id" value="{$view->id}">
	
		<select name="field_key">
			{$smarty.capture.options nofilter}
		</select>
		
		<input type="search" name="q">
	
		<button type="submit" data-role="button" data-theme="b">{'common.filter.add'|devblocks_translate|capitalize}</button>
	</form>
	{/if}
	
	<h3 style="margin:0;padding:0;">Presets</h3>
		
	<form action="{$response_path}" method="post" data-ajax="false">
		<input type="hidden" name="c" value="m">
		<input type="hidden" name="a" value="viewLoadPreset">
		<input type="hidden" name="view_id" value="{$view->id}">
	
		{foreach from=$presets item=preset key=preset_id}
		<button type="submit" name="preset_id" value="{$preset->id}" data-role="button" data-theme="c">{$preset->name}</button>
		{/foreach}
		
		<button type="submit" name="preset_id" value="0" data-role="button" data-theme="b">{'common.reset'|devblocks_translate|capitalize}</button>
	</form>
</div>

<div id="viewSortPopup" data-role="popup" class="ui-content" data-theme="b" data-overlay-theme="a" data-transition="slidedown">
	<h3 style="margin:0;padding:0;">Sort by</h3>
	
	<form action="{$response_path}" method="post" data-ajax="false">
		<input type="hidden" name="c" value="m">
		<input type="hidden" name="a" value="viewSortBy">
		<input type="hidden" name="view_id" value="{$view->id}">
		
		<select name="sort_by">
		{foreach from=$fields item=field key=field_key}
			{if in_array($field_key, $view->view_columns)}
			<option value="{$field_key}" {if $field_key == $view->renderSortBy}selected="selected"{/if}>{$field->db_label|capitalize}</option>
			{/if}
		{/foreach}
		</select>

		<fieldset data-role="controlgroup" data-type="horizontal">
			<input type="radio" name="sort_asc" id="viewWorklistSortAsc" value="1" {if $view->renderSortAsc}checked="checked"{/if} />
			<label for="viewWorklistSortAsc">Ascending</label>
			<input type="radio" name="sort_asc" id="viewWorklistSortDesc" value="0" {if !$view->renderSortAsc}checked="checked"{/if} />
			<label for="viewWorklistSortDesc">Descending</label>
		</fieldset>
		
		<button type="submit" data-role="button" data-theme="b">{'common.save_changes'|devblocks_translate|capitalize}</button>
	</form>
</div>

<div id="view{$view->id}">

<form action="{$response_path}" method="post">
<input type="hidden" name="c" value="m">
<input type="hidden" name="a" value="viewRemoveFilter">
<input type="hidden" name="view_id" value="{$view->id}">
	
	<a href="#viewFiltersPopup" data-rel="popup" data-role="button" data-theme="a" data-mini="true" data-inline="true" data-icon="arrow-d" data-iconpos="right">
		{'common.filters'|devblocks_translate|capitalize}
	</a>
	
	{if !empty($params)}
	{foreach from=$params item=param key=param_key}
		<button type="submit" name="filter_key" value="{$param_key}" data-role="button" data-theme="c" data-mini="true" data-inline="true" data-icon="delete">
		{$fields.$param_key->db_label|capitalize} 
		
		{if $param->operator=='='}
			is
		{elseif $param->operator=='!='}
			is not 
		{elseif $param->operator=='in'}
			is    
		{elseif $param->operator=='in or null'}
			is blank{if !empty($param->value)} or{/if} 
		{elseif $param->operator=='not in'}
			is not
		{elseif $param->operator=='not in or null'}
			is blank{if !empty($param->value)} or not{/if}  
		{elseif $param->operator=='is null'}
			is {if empty($param->value)}blank{/if}
		{elseif $param->operator=='is not null'}
			is not {if empty($param->value)}blank{/if}
		{else} 
			{$param->operator}
		{/if}
		
		{$view->renderCriteriaParam($param)}
		</button>
	{/foreach}
	{/if}
</form>

<a href="#viewSortPopup" data-rel="popup" data-role="button" data-theme="a" data-mini="true" data-inline="true" data-iconpos="right" data-icon="{if $view->renderSortAsc}arrow-u{else}arrow-d{/if}">
	Sorted by:
	{$fields.{$view->renderSortBy}->db_label}
</a>

<div class="choice_list">

	<ul data-role="listview" data-inset="true" data-icon="arrow-r" data-filter="false">
		
	{foreach from=$results item=result key=result_id}
		{CerberusContexts::getContext($context_ext->id, $result_id, $labels, $values, null, true)}
		{$dict = DevblocksDictionaryDelegate::instance($values)}
	
		<li>
			<a href="{devblocks_url}c=m&w=profile&context={$context_ext->id}&context_id={$result_id}{/devblocks_url}" data-transition="slide">
				<h3 class="ui-li-heading">{$dict->_label}</h3>
				
				{if method_exists($context_ext, 'getDefaultProperties')}
				{$props = $context_ext->getDefaultProperties()}
				
				{foreach from=$props item=prop_key}
					{if method_exists($context_ext, 'formatDictionaryValue')}
						{$val = $context_ext->formatDictionaryValue($prop_key, $dict)}
					{else}
						{$val = $dict->$prop_key}
					{/if}
					
					{if strlen($val) > 0}
					<p class="ui-li-desc">
						<b>{$dict->_labels.$prop_key}:</b>
						
						{$val_type = $dict->_types.$prop_key}
						{if $val_type == 'context_url'}
							{if preg_match('#ctx://(.*?):([0-9]+)/*(.*)$#', $val, $matches)}
								{$matches[3]|default:'link'}
							{/if}
							
						{else}
							{$val|escape:'htmlall'|nl2br nofilter}
						{/if}
					</p>
					{/if}
				{/foreach}
				{/if}
			</a>
		</li>
		
	{foreachelse}
		<li>
			This worklist is empty.
		</li>
	
	{/foreach}
	
	</ul>
	
</div>

{if !empty($results)}
<div style="text-align:center;font-size:0.9em;">
<form action="{$response_path}" method="post">
<input type="hidden" name="c" value="m">
<input type="hidden" name="a" value="viewPage">
<input type="hidden" name="view_id" value="{$view->id}">

	{$page_current = $view->renderPage+1}
	{$page_total = ceil($total/$view->renderLimit)}
	
	<div>
		{if $page_current > 1}
		<button type="submit" name="page" value="{$view->renderPage-1}" data-role="button" data-inline="true" data-icon="arrow-l" data-iconpos="notext"></button>
		{/if}
		
		Page {$page_current} of {$page_total} ({$total} results)
		
		{if $page_current < $page_total}
		<button type="submit" name="page" value="{$view->renderPage+1}" data-role="button" data-inline="true" data-icon="arrow-r" data-iconpos="notext"></button>
		{/if}
	</div>
	
	{if $page_current > 1}
	<button type="submit" name="page" value="0" data-role="button" data-inline="true" data-icon="back" data-iconpos="notext"></button>
	{/if}
</form>
</div>
{/if}

</div>