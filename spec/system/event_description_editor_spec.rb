# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Event description editor', :js do
  let(:event) { create(:event, name: 'Winter School', description: '<div>Original</div>') }

  before do
    sign_in create(:admin)
    page.current_window.resize_to(1400, 1000)
    visit edit_event_path(id: event.id)
    find('trix-editor[contenteditable]')
  end

  def load_description(html, position = 0)
    page.execute_script(<<~JS, html, position)
      const element = document.querySelector('trix-editor');
      element.editor.loadHTML(arguments[0]);
      element.focus();
      element.editor.setSelectedRange([arguments[1], arguments[1]]);
    JS
  end

  def paste_html(html)
    page.execute_script(<<~JS, html)
      const element = document.querySelector('trix-editor');
      const clipboard = new DataTransfer();
      clipboard.setData('text/html', arguments[0]);
      const paste = new InputEvent('beforeinput', {
        inputType: 'insertFromPaste', bubbles: true, cancelable: true, dataTransfer: clipboard
      });
      element.dispatchEvent(paste);
    JS
  end

  def editor_text
    page.evaluate_script("document.querySelector('trix-editor').editor.getDocument().toString()")
  end

  it 'keeps Word formatting without adding blank lines from paragraph spacing' do
    load_description('')
    paste_html(<<~HTML)
      <p class="MsoNormal" style="margin-bottom:8pt;line-height:115%">
        <span style="font-weight:700">Welcome</span>
      </p>
      <p class="MsoNormal" style="margin:12pt 0;text-indent:36pt">
        <span style="font-style:italic">Bring lunch</span>
        <a href="https://example.com/details">Details</a>
      </p>
      <ul><li>First activity</li><li>Second activity</li></ul>
    HTML

    expect(page).to have_css('trix-editor strong', text: 'Welcome')
    expect(page).to have_css('trix-editor em', text: 'Bring lunch')
    expect(page).to have_css('trix-editor a[href="https://example.com/details"]')
    expect(page).to have_css('trix-editor li', count: 2)
    expect(editor_text).not_to include("\n\n")

    click_on 'Update Event'
    expect(page).to have_content('Updated Winter School')
    expect(event.reload.description.body.to_html).to include('<strong>Welcome</strong>', '<em>')
    visit edit_event_path(id: event.id)
    expect(page).to have_css('trix-editor li', count: 2)
  end

  it 'preserves intentional empty paragraphs when pasting from Google Docs' do
    load_description('')
    paste_html(<<~HTML)
      <b id="docs-internal-guid-example" style="font-weight:normal">
        <p style="margin:12pt 0">First line</p>
        <p><br></p>
        <p style="margin:12pt 0">Last line</p>
      </b>
    HTML

    expect(page).to have_css('trix-editor', text: 'Last line')
    expect(editor_text).to eq("First line\n\nLast line\n")
  end

  it 'adds exactly one line break per Enter and supports Japanese text' do
    load_description('')
    find('trix-editor').send_keys('First line')
    expect(editor_text).to eq("First line\n")
    find('trix-editor').send_keys(:enter)
    expect(editor_text).to eq("First line\n\n")
    find('trix-editor').send_keys('Second line')
    expect(editor_text).to eq("First line\nSecond line\n")
    find('trix-editor').send_keys(:enter, :enter)
    find('trix-editor').send_keys('日本語の説明')

    expect(editor_text).to eq("First line\nSecond line\n\n日本語の説明\n")
  end

  it 'indents only the current text line and can undo or remove the indentation' do
    load_description('<div>Above<br>Middle<br>Below</div>', 8)
    find('trix-editor').send_keys(:tab)

    expect(editor_text).to eq("Above\n    Middle\nBelow\n")
    find('trix-editor').send_keys(%i[shift tab])
    expect(editor_text).to eq("Above\nMiddle\nBelow\n")

    find('trix-editor').send_keys(:tab)
    page.execute_script("document.querySelector('trix-editor').editor.undo()")
    expect(editor_text).to eq("Above\nMiddle\nBelow\n")
  end

  it 'keeps rapid typing after repeated Enter presses in the correct position' do
    load_description('')
    find('trix-editor').send_keys('First line', :enter, 'Second line', :enter, :enter, '日本語の説明')

    expect(editor_text).to eq("First line\nSecond line\n\n日本語の説明\n")
  end

  it 'indents and outdents selected lines without changing surrounding text' do
    load_description('<div>Above<br>Middle<br>Below<br>Last</div>')
    page.execute_script("document.querySelector('trix-editor').editor.setSelectedRange([6, 18])")
    find('trix-editor').send_keys(:tab)
    expect(editor_text).to eq("Above\n    Middle\n    Below\nLast\n")

    find('trix-editor').send_keys(%i[shift tab])
    expect(editor_text).to eq("Above\nMiddle\nBelow\nLast\n")
  end

  it 'keeps Enter and Shift+Enter working inside a list' do
    load_description('<ul><li>First</li></ul>', 5)
    find('trix-editor').send_keys(:enter, 'Second', %i[shift enter], 'More details')

    expect(page).to have_css('trix-editor li', count: 2)
    expect(page).to have_css('trix-editor li', text: "Second\nMore details")
    expect(editor_text).to eq("First\nSecond\nMore details\n")
  end

  it 'keeps list nesting confined to the current list item' do
    load_description('<ul><li>First</li><li>Second</li><li>Third</li></ul>', 9)
    find('trix-editor').send_keys(:tab)

    expect(page).to have_css('trix-editor > ul > li > ul > li', text: 'Second')
    expect(page).to have_css('trix-editor > ul > li', text: 'Third')
    expect(editor_text).to eq("First\nSecond\nThird\n")
  end

  it 'loads the editor styles and retains visible bullets on the parent-facing page' do
    load_description('<ul><li>Visible bullet</li></ul>')
    styles = page.evaluate_script(<<~JS)
      (() => {
        const element = document.querySelector('trix-editor');
        const toolbarButton = document.querySelector('trix-toolbar button');
        return {
          display: getComputedStyle(element).display,
          align: getComputedStyle(element).textAlign,
          list: getComputedStyle(element.querySelector('li')).listStyleType,
          toolbar: getComputedStyle(toolbarButton).borderStyle
        };
      })()
    JS
    expect(styles).to include('display' => 'block', 'align' => 'left', 'list' => 'disc')
    expect(styles['toolbar']).not_to eq('outset')

    click_on 'Update Event'
    expect(page).to have_content('Updated Winter School')
    parent = create(:customer)
    child = create(:internal_child, parent:)
    sign_out :user
    sign_in parent
    visit new_invoice_path(event_id: event.id, child: child.id)
    find('summary', text: I18n.t('invoices.new.more_info')).click
    expect(page).to have_css('.trix-content li', text: 'Visible bullet')
    list_style = page.evaluate_script(<<~JS)
      getComputedStyle(document.querySelector('.trix-content li')).listStyleType
    JS
    expect(list_style).to eq('disc')
  end

  it 'updates the matching events from the full edit form' do
    matching = create(:event, name: event.name)
    visit edit_event_path(id: event.id, apply_to_matching_events: '1')
    expect(page).to have_checked_field('apply_to_matching_events')
    load_description('<div><strong>Shared event details</strong></div>')
    fill_in 'Name', with: 'Shared Winter School'
    fill_in 'Goal', with: '50000'

    click_on 'Update Event'

    expect(page).to have_content('Updated Event Fields across 2 events.')
    expect(matching.reload).to have_attributes(name: 'Shared Winter School', goal: 50_000)
    expect(matching.description.body.to_html).to include('<strong>Shared event details</strong>')
  end
end
