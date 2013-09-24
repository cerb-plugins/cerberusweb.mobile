<div data-role="dialog" data-close-btn="right">
	<div data-role="header" data-theme="f">
		<h1>Virtual Attendants</h1>
	</div>
	
	<div data-role="content">
	
		<div class="choice_list">
		<ul data-role="listview" data-inset="false" data-icon="arrow-r" data-filter="false" data-theme="c">
		{foreach from=$vas item=va}
			{capture name=behaviors}
			{foreach from=$macros item=macro}
				{if $macro->virtual_attendant_id == $va->id}
					<li>
						<a href="{devblocks_url}ajax.php?c=m&a=showVaBehaviorDialog&context={$context}&context_id={$context_id}&behavior_id={$macro->id}{/devblocks_url}" data-rel="dialog">
							{$macro->title}
						</a>
					</li>
				{/if}
			{/foreach}
			{/capture}
			
			{if strlen(trim($smarty.capture.behaviors))}
			<li data-role="list-divider" data-theme="h">
				{$va->name}
			</li>
			{$smarty.capture.behaviors nofilter}
			{/if}
		{/foreach}
		</ul>
		</div>
	
	</div>
</div>