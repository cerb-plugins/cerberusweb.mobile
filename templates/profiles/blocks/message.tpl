<h3>Message</h3>

<div style="font-size:12px;">
	{$dict->created|devblocks_prettytime}, <b>{$dict->sender__label}</b> wrote:
	<div class="cerb-message-contents">{$dict->content|trim|escape:'htmlall'|devblocks_hyperlinks nofilter}</div>
</div>