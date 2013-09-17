{$data = $view->getData()}
{$results = $data.0}
{$total = $data.1}

{$context_ext = Extension_DevblocksContext::getByViewClass(get_class($view), true)}

{$fields = $view->getFields()}
{$params = $view->getEditableParams()}
{$presets = $view->getPresets()}

{if !$hide_filtering}
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
	<form action="javascript:;" method="post" class="cerb-form-worklist-search" onsubmit="return false;">
		<input type="hidden" name="c" value="m">
		<input type="hidden" name="a" value="viewQuickSearch">
		<input type="hidden" name="view_id" value="{$view->id}">
		<input type="hidden" name="hide_filtering" value="{$hide_filtering}">
		<input type="hidden" name="hide_sorting" value="{$hide_sorting}">
	
		<select name="field_key">
			{$smarty.capture.options nofilter}
		</select>
		
		<input type="search" name="q">
	
		<button type="button" class="submit" data-role="button" data-theme="b">{'common.filter.add'|devblocks_translate|capitalize}</button>
	</form>
	{/if}
	
	<h3 style="margin:0;padding:0;">Presets</h3>
		
	<form action="javascript:;" method="post" class="cerb-form-worklist-presets" onsubmit="return false;">
		<input type="hidden" name="c" value="m">
		<input type="hidden" name="a" value="viewLoadPreset">
		<input type="hidden" name="view_id" value="{$view->id}">
		<input type="hidden" name="hide_filtering" value="{$hide_filtering}">
		<input type="hidden" name="hide_sorting" value="{$hide_sorting}">

		{foreach from=$presets item=preset key=preset_id}
		<button type="button" class="submit" name="preset_id" value="{$preset->id}" data-role="button" data-theme="c">{$preset->name}</button>
		{/foreach}
		
		<button type="button" class="submit" name="preset_id" value="0" data-role="button" data-theme="b">{'common.reset'|devblocks_translate|capitalize}</button>
	</form>
</div>
{/if}

{if !$hide_sorting}
<div id="viewSortPopup" data-role="popup" class="ui-content" data-theme="b" data-overlay-theme="a" data-transition="slidedown">
	<h3 style="margin:0;padding:0;">Sort by</h3>
	
	<form action="javascript:;" method="post" class="cerb-form-worklist-sorting" onsubmit="return false;">
		<input type="hidden" name="c" value="m">
		<input type="hidden" name="a" value="viewSortBy">
		<input type="hidden" name="view_id" value="{$view->id}">
		<input type="hidden" name="hide_filtering" value="{$hide_filtering}">
		<input type="hidden" name="hide_sorting" value="{$hide_sorting}">
		
		<select name="sort_by">
		{foreach from=$fields item=field key=field_key}
			{if in_array($field_key, $view->view_columns)}
			<option value="{$field_key}" {if $field_key == $view->renderSortBy}selected="selected"{/if}>{$field->db_label|capitalize}</option>
			{/if}
		{/foreach}
		</select>

		<input type="radio" name="sort_asc" id="viewWorklistSortAsc" value="1" {if $view->renderSortAsc}checked="checked"{/if} />
		<label for="viewWorklistSortAsc">Ascending</label>
		
		<input type="radio" name="sort_asc" id="viewWorklistSortDesc" value="0" {if !$view->renderSortAsc}checked="checked"{/if} />
		<label for="viewWorklistSortDesc">Descending</label>
		
		<button type="button" class="submit" data-role="button" data-theme="b">{'common.save_changes'|devblocks_translate|capitalize}</button>
	</form>
</div>
{/if}

{if !$hide_filtering}
<form action="javascript:;" method="post" class="cerb-form-worklist-filtering" onsubmit="return false;">
<input type="hidden" name="c" value="m">
<input type="hidden" name="a" value="viewRemoveFilter">
<input type="hidden" name="view_id" value="{$view->id}">
<input type="hidden" name="hide_filtering" value="{$hide_filtering}">
<input type="hidden" name="hide_sorting" value="{$hide_sorting}">
	
	<a href="#viewFiltersPopup" data-rel="popup" data-role="button" data-theme="a" data-mini="true" data-inline="true" data-icon="arrow-d" data-iconpos="right">
		{'common.filters'|devblocks_translate|capitalize}
	</a>
	
	{if !empty($params)}
	{foreach from=$params item=param key=param_key}
		<button type="button" class="submit" name="filter_key" value="{$param_key}" data-role="button" data-theme="c" data-mini="true" data-inline="true" data-icon="delete">
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
{/if}

{if !$hide_sorting}
<a href="#viewSortPopup" data-rel="popup" data-role="button" data-theme="a" data-mini="true" data-inline="true" data-iconpos="right" data-icon="{if $view->renderSortAsc}arrow-u{else}arrow-d{/if}">
	Sorted by:
	{$fields.{$view->renderSortBy}->db_label}
</a>
{/if}

<div class="choice_list">

	<ul data-role="listview" data-inset="true" data-icon="arrow-r" data-filter="false">

	{foreach from=$results item=result key=result_id}
		{CerberusContexts::getContext($context_ext->id, $result_id, $labels, $values, null, true)}
		{$dict = DevblocksDictionaryDelegate::instance($values)}
	
		{if method_exists($context_ext, 'getPropertyLabels')}
			{$prop_labels = $context_ext->getPropertyLabels($dict)}
		{else}
			{$prop_labels = $dict->_labels}
		{/if}
		
		<li>
			<a href="{devblocks_url}c=m&w=profile&context={$context_ext->id}&context_id={$result_id}{/devblocks_url}" data-transition="slide" style="margin:0;padding:5px 5px;">

			<h3 style="margin:5px;">{$dict->_label}</h3>
			
			{if method_exists($context_ext, 'getDefaultProperties')}
			{$props = $context_ext->getDefaultProperties()}
			
			<table cellspacing="2" cellpadding="2" width="100%" border="0" style="font-size:12px;font-weight:normal;white-space:normal;word-wrap:break-word;word-break:break-word;">
			{foreach from=$props item=prop_key}
				{if method_exists($context_ext, 'formatDictionaryValue')}
					{$val = $context_ext->formatDictionaryValue($prop_key, $dict)}
				{else}
					{$val = $dict->$prop_key}
				{/if}
				
				{if strlen($val) > 0}
				<tr>
					<td style="width:30%;" valign="top">
						<div style="font-weight:bold;padding-left:5px;text-indent:-5px;">{$prop_labels.$prop_key}:</div>
					</td>
					<td style="width:70%;padding-left:5px;">
						{$val_type = $dict->_types.$prop_key}
						
						{if $val_type == 'context_url' && substr($val,0,6) == 'ctx://'}
							{if preg_match('#ctx://(.*?):([0-9]+)/*(.*)$#', $val, $matches)}
								{$matches[3]|default:'link'}
								{*<a href="{devblocks_url}c=m=&p=profile&ctx={$matches[1]}&id={$matches[2]}{/devblocks_url}" data-transition="slide">{$matches[3]|default:'link'}</a>*}
							{/if}
							
						{else}
							{$val|escape:'htmlall'|nl2br nofilter}
						{/if}
					</td>
				</tr>
				{/if}
			{/foreach}
			</table>
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

{$page_current = $view->renderPage+1}
{$page_total = ceil($total/$view->renderLimit)}

{if $page_total > 1}
<div style="text-align:center;font-size:0.9em;">
<form action="javascript:;" method="post" class="cerb-form-worklist-paging" onsubmit="return false;">
<input type="hidden" name="c" value="m">
<input type="hidden" name="a" value="viewPage">
<input type="hidden" name="view_id" value="{$view->id}">
<input type="hidden" name="hide_filtering" value="{$hide_filtering}">
<input type="hidden" name="hide_sorting" value="{$hide_sorting}">
	
	<div>
		{if !$hide_paging && $page_current > 1}
		<button type="button" class="prev" data-role="button" data-inline="true" data-icon="arrow-l" data-iconpos="notext"></button>
		{/if}
		
		Page {$page_current} of {$page_total} ({$total} results)
		
		{if !$hide_paging && $page_current < $page_total}
		<button type="button" class="next" data-role="button" data-inline="true" data-icon="arrow-r" data-iconpos="notext"></button>
		{/if}
	</div>
	
	{if !$hide_paging && $page_current > 1}
	<button type="button" class="first" data-role="button" data-inline="true" data-icon="back" data-iconpos="notext"></button>
	{/if}
</form>
</div>
{/if}

<script type="text/javascript">
var $view = $('#view{$view->id}');

var $frm_search = $view.find('form.cerb-form-worklist-search');
var $frm_presets = $view.find('form.cerb-form-worklist-presets');
var $frm_filtering = $view.find('form.cerb-form-worklist-filtering');
var $frm_sorting = $view.find('form.cerb-form-worklist-sorting');
var $frm_paging = $view.find('form.cerb-form-worklist-paging');

/* Search */

$frm_search.find('button.submit').click(function() {
	var $this = $(this);
	var $frm_search = $this.closest('form');
	
	$.mobile.loading('show');
	$.post(
		'{devblocks_url}ajax.php{/devblocks_url}',
		$frm_search.serialize(),
		function(out) {
			$('#viewFiltersPopup').remove();
			$view.html(out).trigger('create');
			$.mobile.loading('hide');
			$.mobile.silentScroll(0);
		}
	);
});

/* Presets */

$frm_presets.find('button.submit').click(function() {
	var $this = $(this);
	var $frm_presets = $this.closest('form');
	var preset_id = $this.val();
	
	$.mobile.loading('show');
	$.post(
		'{devblocks_url}ajax.php{/devblocks_url}?preset_id=' + preset_id,
		$frm_presets.serialize(),
		function(out) {
			$('#viewFiltersPopup').remove();
			$('#viewSortPopup').remove();
			$view.html(out).trigger('create');
			$.mobile.loading('hide');
			$.mobile.silentScroll(0);
		}
	);
});

/* Filtering */

$frm_filtering.find('button.submit').click(function() {
	var $this = $(this);
	var $frm_filtering = $this.closest('form');
	var filter_key = $this.val();
	
	$.mobile.loading('show');
	$.post(
		'{devblocks_url}ajax.php{/devblocks_url}?filter_key=' + filter_key,
		$frm_filtering.serialize(),
		function(out) {
			$('#viewFiltersPopup').remove();
			$('#viewSortPopup').remove();
			$view.html(out).trigger('create');
			$.mobile.loading('hide');
			$.mobile.silentScroll(0);
		}
	);
});

/* Sorting */

$frm_sorting.find('button.submit').click(function() {
	var $this = $(this);
	var $frm_sorting = $this.closest('form');
	
	$.mobile.loading('show');
	$.post(
		'{devblocks_url}ajax.php{/devblocks_url}',
		$frm_sorting.serialize(),
		function(out) {
			$('#viewFiltersPopup').remove();
			$('#viewSortPopup').remove();
			$view.html(out).trigger('create');
			$.mobile.loading('hide');
			$.mobile.silentScroll(0);
		}
	);
});

/* Paging */

$frm_paging.find('button.first').click(function() {
	var $this = $(this);
	var $frm_paging = $this.closest('form');
	
	$.mobile.loading('show');
	$.post(
		'{devblocks_url}ajax.php{/devblocks_url}?page=0',
		$frm_paging.serialize(),
		function(out) {
			$('#viewFiltersPopup').remove();
			$('#viewSortPopup').remove();
			$view.html(out).trigger('create');
			$.mobile.loading('hide');
			$.mobile.silentScroll(0);
		}
	);
});

$frm_paging.find('button.prev').click(function() {
	var $this = $(this);
	var $frm_paging = $this.closest('form');
	
	$.mobile.loading('show');
	$.post(
		'{devblocks_url}ajax.php{/devblocks_url}?page={$view->renderPage-1}',
		$frm_paging.serialize(),
		function(out) {
			$('#viewFiltersPopup').remove();
			$('#viewSortPopup').remove();
			$view.html(out).trigger('create');
			$.mobile.loading('hide');
			$.mobile.silentScroll(0);
		}
	);
});

$frm_paging.find('button.next').click(function() {
	var $this = $(this);
	var $frm_paging = $this.closest('form');
	
	$.mobile.loading('show');
	$.post(
		'{devblocks_url}ajax.php{/devblocks_url}?page={$view->renderPage+1}',
		$frm_paging.serialize(),
		function(out) {
			$('#viewFiltersPopup').remove();
			$('#viewSortPopup').remove();
			$view.html(out).trigger('create');
			$.mobile.loading('hide');
			$.mobile.silentScroll(0);
		}
	);
});

</script>