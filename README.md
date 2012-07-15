# TwitterBootstrapFormBuilder

A gem for building **horzontal** (vertial/search/inline coming soon) Twitter Bootstrap forms, automagically handling the
control-group markup, field labels and inline-error messages.

## Installation

Add this line to your application's Gemfile:

    gem 'twitter-bootstrap-form-builder'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install twitter-bootstrap-form-builder

## QuickStart

### app/helpers/application_helper.rb

```ruby
module ApplicationHelper
  # Replace form_for
  include MNE::TwitterBootstrapFormBuilder
end
```

### Using the form builder

```erb
<% # Labels and control-group markup are handled by the form builder %>

<%= form_for @post do |f| %>
  <%= f.text_field :topic %>
  <%= f.text_area :body %>
  <div class="form-actions">
    <%= f.submit "Create Post" %>
  </div>
<% end %>
```


## Usage

Twitter Bootstrap FormBuilder is designed to output all the markup required to build **horzontal** forms,
with minimal typing.

After installing the Gem, you can use the special `form_for` helper by mixing `TwitterBootstrapFormBuilder::Helper`
into your Helper modules, which will automatically add the `form-horizontal` class to your `<form>` tag,
and set the `:builder` to `TwitterBootstrapFormBuilder`. That is, the following are roughly equivalent:

```ruby
# Using the TBFB helper:
form_for @post do |f|

# Using the regular form_for helper
form_for @post, :builder => MNE::TwitterBootstrapFormBuilder::FormBuilder, :html => { :class => "form-horizontal" } do |f|
```

### Using the FormBuilder:

The various `*_field` and `select` methods will output the full markup for a control group, including labels.

The following `text_field`...

```erb
<%= form_for @post do |f| %>
  <%= f.text_field :subject %>
```

Outputs the following HTML:

```html
<div class="text_field control-group subject">
  <label for="post_subject">Subject</label>
  <div class="controls">
     <input type="text" name="post[subject]" id="post_subject" value="..." />
  </div>
</div>
```

If you need to override the text of the label, use `:label`:

```erb
<%= f.text_field :email, :label => "Email Address" %>
```

If you want to turn off the helper entirely and output *just* the text field, exactly as if you were calling
the regular `FormBuilder#text_field`, use `:label => false`:

```erb
<%= f.text_field :email, :label => false %> # <input type="text" id="post_email" />
```

### Errors and validation

The TwitterBootstrapFormBuilder relies on the dynamic_form gem to output inline error messages.

Outputting a field with errors will add an inline error message and decorate the top-level control-group with an
`error` class, causing the field inside to be outlined in Red by bootstrap.css

Given a post with a "can't be blank" error on the topic field:

```erb
<%= form_for @post do |f| %>
  <%= f.text_field :topic %>
<% end %>
```

The following will be produced (a mixture of Rail's `field_with_errors` and Bootstrap-specific classes):

```html
<div class="text_field control-group topic error">
  <div class="field_with_errors">
    <label for="post_topic">Topic</label>
  </div>
  <div class="controls">
    <div class="field_with_errors">
      <input type="text" name="post[topic]" value="..." />
    </div>
    <p class="help-block">Topic can't be blank</p>
  </div>
</div>
```

Note that both the `label` and `input` elements are still wrapped in `<div class="field_with_errors">` by the base
FormBuilder. In addition, a `<p class="help-block">` is output below the field containing the error message.

### Rendering just some fields:

```erb
<%= fields_for @post, :builder => MNE::TwitterBootstrapFormBuilder::FormBuilder do |f| %>
```

### Other helpers

If you want to output your own control group, you can use the `control_group` method to help with the markup.

```erb
<%= f.control_group :topic %> <!-- div class="control-group topic [error]" -->
  <%= f.label :topic %>
  <div class="controls">
    <%= f.text_field :topic, :label => false %>
    <div class="errors">
      <%= f.errors_for :topic %><!-- as provided by dynamic_form -->
    </div>
  </div>
<% end %>
```

## Examples

Here is a basic form for a PhotoSet, which contains a title and description attribute.
The form has been posted back, causing a `validates_presence_of` validator to fail on the `title` field:

Form:

```erb
<%= form_for [:admin, @photo_set] do |f| %>
  <%= f.text_field :title %>
  <%= f.text_area :description %>

  <div class="form-actions">
    <%= f.submit "Create Photo Set" %>
  </div>
<% end %>
```

Output (cleaned up and indented):

```html
<form accept-charset="UTF-8" action="/admin/photo_sets" class="form-horizontal" id="new_photo_set" method="post">
	<div style="margin:0;padding:0;display:inline">
		<input name="utf8" type="hidden" value="&#x2713;" />
		<input name="authenticity_token" type="hidden" value="nVRM9bXgeD2s/WGum+fJMy9dMYSNVCzYR6/U0Pg+068=" />
	</div>
	<div class="text_field control-group title error">
		<div class="field_with_errors">
			<label class="control-label" for="photo_set_title">Title</label>
		</div>
		<div class="controls">
			<div class="field_with_errors">
				<input id="photo_set_title" name="photo_set[title]" size="30" type="text" value="" />
			</div>
			<p class="help-block">Title can't be blank</p>
		</div>
	</div>
	<div class="text_area control-group description">
		<label class="control-label" for="photo_set_description">Description</label>
		<div class="controls">
			<textarea cols="40" id="photo_set_description" name="photo_set[description]" rows="20">

			</textarea>
		</div>
	</div>
	<div class="form-actions">
		<input name="commit" type="submit" value="Create Photo Set" />
	</div>
</form>
```



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
