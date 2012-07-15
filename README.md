# Twitter::Bootstrap::Form::Builder

A gem for building **horzontal** Twitter Bootstrap forms, automagically handling the
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

    module ApplicationHelper
      # Replace form_for
      include MNE::TwitterBootstrapFormBuilder
    end


### Using the form builder

    # Labels and control-group markup are handled by the form builder
    
    <%= form_for @post do |f| %>
      <%= f.text_field :topic %>
      <%= f.text_area :body %>
      <div class="form-actions">
        <%= f.submit "Create Post" %>
      </div>
    <% end %>

### Rendering just some fields:

    <%= fields_for @post, :builder => MNE::TwitterBootstrapFormBuilder::FormBuilder do |f| %>
      ....
    
## Usage

Twitter Bootstrap FormBuilder is designed to output all the markup required to build **horzontal** forms,
with minimal typing.

After installing the Gem, you can use the special `form_for` helper by mixing `TwitterBootstrapFormBuilder::Helper`
into your Helper modules, which will automatically add the `form-horizontal` class to your `<form>` tag,
and set the `:builder` to `TwitterBootstrapFormBuilder`. That is, the following are roughly equivalent:

    # Using the TBFB helper:
    form_for @post do |f|

    # Using the regular form_for helper
    form_for @post, :builder => MNE::TwitterBootstrapFormBuilder::FormBuilder, :html => { :class => "form-horizontal" } do |f|

### Using the FormBuilder:

The various `*_field` and `select` methods will output the full markup for a control group, including labels.

The following `text_field`...

    <%= form_for @post do |f| %>
      <%= f.text_field :subject %>

Outputs the following HTML:

    <div class="text_field control-group subject">
      <label for="post_subject">Subject</label>
      <div class="controls">
         <input type="text" name="post[subject]" id="post_subject" value="..." />
      </div>
    </div>
    
If you need to override the text of the label, use `:label`:

    <%= f.text_field :email, :label => "Email Address" %>

If you want to turn off the helper entirely and output *just* the text field, exactly as if you were calling
the regular `FormBuilder#text_field`, use `:label => false`:

    <%= f.text_field :email, :label => false %> # <input type="text" id="post_email" />

### Errors and validation

The TwitterBootstrapFormBuilder relies on the dynamic_form gem to output inline error messages.

Outputting a field with errors will add an inline error message and decorate the top-level control-group with an
`error` class, causing the field inside to be outlined in Red by bootstrap.css

Given a post with a "can't be blank" error on the topic field:

    <%= form_for @post do |f| %>
      <%= f.text_field :topic %>
    <% end %>
    
The following will be produced (a mixture of Rail's `field_with_errors` and Bootstrap-specific classes):

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

Note that both the `label` and `input` elements are still wrapped in `<div class="field_with_errors">` by the base
FormBuilder. In addition, a `<p class="help-block">` is output below the field containing the error message.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
