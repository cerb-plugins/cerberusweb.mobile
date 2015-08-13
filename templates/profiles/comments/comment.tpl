{$uniqid = uniqid()}

{$page_total = $comments|count}
{$comments_timeline = array_keys($comments)}
{$comment_index = array_search($dict->id, $comments_timeline)}
{$page_current = $comment_index + 1}

{capture name=comment_paging}
{if $page_total > 0}
<div style="text-align:center;background-color:rgb(242,242,242);border:2px solid rgb(242,242,242);border-bottom-width:1px;border-radius:8px 8px 0px 0px;">
<form action="javascript:;" method="post" class="cerb-profile-comment-form{$uniqid}" onsubmit="return false;">
<input type="hidden" name="c" value="m">
<input type="hidden" name="a" value="profileGetComment">
<input type="hidden" name="context" value="{$context}">
<input type="hidden" name="context_id" value="{$context_id}">
<input type="hidden" name="_csrf_token" value="{$session.csrf_token}">

	<table width="100%" cellpadding="0" cellspacing="0" border="0" style="min-height:32px;">
		<tr>
			<td align="left" width="15%">
				{if $page_current > 1}
				<button type="button" class="prev ui-icon-nodisc" data-role="button" data-inline="true" data-icon="carat-l" data-iconpos="notext"></button>
				{/if}
			</td>
			
			<td align="center" width="70%" style="font-size:16px;color:#000;">
				<b>{$page_current} of {$page_total}</b>
			</td>
			
			<td align="right" width="15%">
				{if $page_current < $page_total}
				<button type="button" class="next ui-icon-nodisc" data-role="button" data-inline="true" data-icon="carat-r" data-iconpos="notext"></button>
				{/if}
			</td>
		</tr>
	</table>
	
</form>
</div>
{/if}
{/capture}

<div class="cerb-message-paging-bottom">
{$smarty.capture.comment_paging nofilter}
</div>

{if $dict->id}
<div class="cerb-message-contents"><span style="color:rgb(75,75,75);font-style:italic;">{$dict->created|devblocks_prettytime}, <b>{$dict->author_label}</b> ({$dict->author_type}) wrote:</span>

{$dict->comment|trim|truncate:25000|escape:'htmlall'|devblocks_hyperlinks nofilter}</div>
{/if}

<a href="{devblocks_url}ajax.php?c=m&a=profileAddCommentDialog&context={$context}&context_id={$context_id}{/devblocks_url}" data-rel="dialog" data-transition="flip" data-role="button">Add Comment</a>

<script type="text/javascript">
$(function() {
	var $frm = $('form.cerb-profile-comment-form{$uniqid}');
	
	$frm.find('button.prev').on('click', function() {
		$.mobile.loading('show');
		$.get(
			'{devblocks_url}ajax.php?c=m&a=profileGetComment&id={$comments_timeline[{$comment_index-1}]}{/devblocks_url}',
			function(html) {
				$.mobile.activePage.find('div.cerb-profile-comment').html(html).trigger('create');
				$.mobile.loading('hide');
			}
		);
	});
	
	$frm.find('button.next').on('click', function() {
		$.mobile.loading('show');
		$.get(
			'{devblocks_url}ajax.php?c=m&a=profileGetComment&id={$comments_timeline[{$comment_index+1}]}{/devblocks_url}',
			function(html) {
				$.mobile.activePage.find('div.cerb-profile-comment').html(html).trigger('create');
				$.mobile.loading('hide');
			}
		);
	});
});
</script>