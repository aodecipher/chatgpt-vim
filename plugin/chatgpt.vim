if $OPENAI_API_TOKEN != ''
  let g:openaiToken = $OPENAI_API_TOKEN
else
  let g:openaiToken = system('printf "%s" "$(cat ~/.config/openai.token)"')
endif


function! OpenAI_test(prompt, temper)
  let prompt = substitute(a:prompt, "[\"']", "\\\\&", "g")
  let temper = a:temper
  " echo temper
  " Embed a Python function
python3 << EOF
import vim
import openai
import os
# Path to the openai.token file in the user's home directory
token_file_path = os.path.expanduser("~/.config/openai.token")
model_engine = "gpt-3.5-turbo"  # Use the Gpt-3 model

# Read the contents of the token file into a variable called key_var
with open(token_file_path, "r") as f:
    api_key = f.read().strip()

openai.api_key = api_key

def generate_response(prompt, temper):
    response = openai.ChatCompletion.create(
      model=model_engine,
      temperature=float(temper),
      max_tokens=200,
      messages=[
            {"role": "user", "content": "{}".format(prompt)},
        ]
    )
    return response.choices[0].message.content

# Call the Python function and pass the Vimscript argument
result = generate_response(vim.eval("prompt"), vim.eval("temper"))

vim.command("let response = '" + result.replace("'", "''") + "'")
EOF
  return response
endfunction

function! GTPwithTimeout(prompt, temper)
  " Set the timeout to 2 seconds
  let timeout = 10000

  " Start the timer
  let timer = timer_start(timeout, 'ChatTimeoutCallback')

  " Perform some long-running operation
  let response =  OpenAI_chat(a:prompt, a:temper)

  " Stop the timer if it hasn't already fired
  if timer != 0
    call timer_stop(timer)
  endif
  " echo response
  return response
endfunction

function! ChatTimeoutCallback(timer)
  " Handle the timeout event here
  echo "Timeout occurred!"
endfunction

function! OpenAI_latest(prompt, temper)
  " let prompt = substitute(a:prompt, "[\"']", "\\\\&", "g")
  let prompt = a:prompt
  let temper = a:temper
  " Embed a Python function
python3 << EOF
import vim
import openai
import os
# Path to the openai.token file in the user's home directory
token_file_path = os.path.expanduser("~/.config/openai.token")
#model_engine = "gpt-3.5-turbo"  # Use the Gpt-3 model
model_engine = "gpt-4"  # Use the Gpt-3 model

# Read the contents of the token file into a variable called key_var
with open(token_file_path, "r") as f:
    api_key = f.read().strip()

openai.api_key = api_key

def generate_response(prompt, temper):
    response = openai.ChatCompletion.create(
      model=model_engine,
      temperature=float(temper),
      max_tokens=1000,
      messages=[
            {"role": "user", "content": "{}".format(prompt)},
        ]
    )
    return response.choices[0].message.content

# Call the Python function and pass the Vimscript argument
result = generate_response(vim.eval("prompt"), vim.eval("temper"))

vim.command("let response = '" + result.replace("'", "''") + "'")
EOF
  return response
endfunction

function! OpenAI_chat(prompt, temper)
  " let prompt = substitute(a:prompt, "[\"']", "\\\\&", "g")
  let prompt = a:prompt
  let temper = a:temper
  " Embed a Python function
python3 << EOF
import vim
import openai
import os
# Path to the openai.token file in the user's home directory
token_file_path = os.path.expanduser("~/.config/openai.token")
model_engine = "gpt-3.5-turbo"  # Use the Gpt-3 model
#model_engine = "gpt-4"  # Use the Gpt-3 model

# Read the contents of the token file into a variable called key_var
with open(token_file_path, "r") as f:
    api_key = f.read().strip()

openai.api_key = api_key

def generate_response(prompt, temper):
    response = openai.ChatCompletion.create(
      model=model_engine,
      temperature=float(temper),
      max_tokens=1000,
      messages=[
            {"role": "user", "content": "{}".format(prompt)},
        ]
    )
    return response.choices[0].message.content

# Call the Python function and pass the Vimscript argument
result = generate_response(vim.eval("prompt"), vim.eval("temper"))

vim.command("let response = '" + result.replace("'", "''") + "'")
EOF
  return response
endfunction

function! GptGenLatest()
  normal me
  let [line_start, column_start] = getpos("'<")[1:2]
  let [line_end, column_end] = getpos("'>")[1:2]
  let lines = getline(line_start, line_end)
  if len(lines) == 0
    let prompt = ''
  else
    let lines[-1] = lines[-1][: column_end - 2]
    let lines[0] = lines[0][column_start - 1:]
    let prompt = join(lines, "\n")
  endif

  echo "Question sent, please wait ..."

  let temper = 0.7
  let output = OpenAI_latest(prompt, temper)
  echo output
  if confirm("Write output at cursor position? (Y/n)", "&Yes\n&No") == 1
    normal m1}o
    call feedkeys("i")
    call feedkeys(output)
    call feedkeys("\<CR>\<Esc>'1")
  endif
endfunction

function! GptGen()
  normal me
  let [line_start, column_start] = getpos("'<")[1:2]
  let [line_end, column_end] = getpos("'>")[1:2]
  let lines = getline(line_start, line_end)
  if len(lines) == 0
    let prompt = ''
  else
    let lines[-1] = lines[-1][: column_end - 2]
    let lines[0] = lines[0][column_start - 1:]
    let prompt = join(lines, "\n")
  endif

  echo "Question sent, please wait ..."

  let temper = 0.7
  let output = GTPwithTimeout(prompt, temper)
  echo output
  if confirm("Write output at cursor position? (Y/n)", "&Yes\n&No") == 1
    normal m1}o
    call feedkeys("i\<CR>")
    call feedkeys(output)
    call feedkeys("\<CR>\<Esc>'1")
  endif
endfunction

" 

function! GptClearnUp()
  normal me
  let [line_start, column_start] = getpos("'<")[1:2]
  let [line_end, column_end] = getpos("'>")[1:2]
  let lines = getline(line_start, line_end)
  if len(lines) == 0
    let prompt = ''
  else
    let lines[-1] = lines[-1][: column_end - 2]
    let lines[0] = lines[0][column_start - 1:]
    let prompt = join(lines, "\n")
    let prompt = "Clean up the typesetting of the following text:\n" . prompt
  endif

  echo "Question sent, please wait ..."

  let temper = 0.2
  let output = GTPwithTimeout(prompt, temper)
  echo output
  if confirm("Write output at cursor position? (Y/n)", "&Yes\n&No") == 1
    normal m1V}c
    call feedkeys("i")
    call feedkeys(output)
    call feedkeys("\<CR>\<Esc>'1")
  endif
endfunction

function! GptGrammar(C)
  normal me
  let [line_start, column_start] = getpos("'<")[1:2]
  let [line_end, column_end] = getpos("'>")[1:2]
  let lines = getline(line_start, line_end)
  if len(lines) == 0
    let prompt = ''
  else
    let lines[-1] = lines[-1][: column_end - 2]
    let lines[0] = lines[0][column_start - 1:]
    let prompt = join(lines, "\n")
    if a:C == 'c'
      let prefix = "In the following paragraphs, if there are any grammatical errors, mark the beginning and ending of the error by double quotes, followed by an explanation enclosed in a pair of square brakets. Special attention should be paid to tense errors. Finally, all errors in capitalization and punctuation should be ignored. \n"
    else
      let prefix = "In the following paragraphs, correct all grammatical errors if any, paying special attention to tense. All errors in capitalization and punctuation should be ignored. \n"
    endif
    let prompt = prefix . prompt
  endif

  echo "Question sent, please wait ..."

  let temper = 0.2
  let output = GTPwithTimeout(prompt, temper)
  echo output
  if confirm("Write output at cursor position? (Y/n)", "&Yes\n&No") == 1
    normal m1V}c
    call feedkeys("i")
    call feedkeys(output)
    call feedkeys("\<CR>\<Esc>'1")
  endif
endfunction

function! GptEdit()
  normal me
  let [line_start, column_start] = getpos("'<")[1:2]
  let [line_end, column_end] = getpos("'>")[1:2]
  let lines = getline(line_start, line_end)
  if len(lines) == 0
    let prompt = ''
  else
    let lines[-1] = lines[-1][: column_end - 2]
    let lines[0] = lines[0][column_start - 1:]
    let prompt = join(lines, "\n")
    let prefix = "improve the following:\n"
    let prompt = prefix . '"""' . prompt . '"""'
  endif

  echo "Question sent, please wait ..."

  let temper = 0.2
  let output = GTPwithTimeout(prompt, temper)
  echo output
  if confirm("Write output at cursor position? (Y/n)", "&Yes\n&No") == 1
    normal m1}o
    call feedkeys("i")
    call feedkeys(output)
    call feedkeys("\<CR>\<Esc>'1")
  endif
endfunction

function! GptAnalyze(L)
  if a:L == 'f'
    let prefix = "Given the following paragraphs, first translate it to French as a male speaker, in an informal tone that suits casual conversations. In particular, do not use vous. Then list all parts of the sentences in the French tranlation with their corresponding parts in the original text. The list of French parts should be placed on a single line, and different French parts should be seperated by a vertical bar. For example, if given \"Hi, how are you?\", the translation may be \"Salut, comment ca va?\". The list of French parts should be in the format of: \"Salut: Hi | comment: how | ça: it | va: goes\"\n"
  elseif a:L == 'e'
    let prefix = "Translate the following paragraphs into English, and then list all parts of sentences with their corresponding parts of sentences in the english translation. The list of parts should be placed on a single line, and different parts should be seperated by a vertical bar. For example, given the French text \"Il est difficile de répondre.\", the translation may be \"It is difficult to answer.\". The list of parts should be in the format of \"Il: It | est: is | difficile: difficult | de: to | répondre: answer\"."
  else
    echo "Wrong Language argument"
    return
  endif
  normal me
  let [line_start, column_start] = getpos("'<")[1:2]
  let [line_end, column_end] = getpos("'>")[1:2]
  let lines = getline(line_start, line_end)
  if len(lines) == 0
    let prompt = ''
  else
    let lines[-1] = lines[-1][: column_end - 2]
    let lines[0] = lines[0][column_start - 1:]
    let prompt = join(lines, "\n")
    let prompt = prefix . '"""' . prompt . '"""'
  endif

  echo "Question sent, please wait ..."

  let temper = 0.2
  let output = GTPwithTimeout(prompt, temper)
  echo output
  if confirm("Write output at cursor position? (Y/n)", "&Yes\n&No") == 1
    normal m1}o
    call feedkeys("i")
    call feedkeys(output)
    call feedkeys("\<CR>\<Esc>'1")
  endif
endfunction

function! GptTranslate(L)
  if a:L == 'f'
    let prefix = "Translate the following into Traditional French, as a male speaker, in an informal tone that suits casual conversations. In particular, do not use vous.:\n"
  elseif a:L == 'e'
    let prefix = "Translate the following into English:\n"
  elseif a:L == 'h'
    let prefix = "Translate the following into Traditional Chinese:\n"
  elseif a:L == 'c'
    let prefix = "Translate the following into Simplified Chinese:\n"
  elseif a:L == 'i'
    let prefix = "Translate the following into Indonesian:\n"
  else
    echo "Wrong Language argument"
    return
  endif
  normal me
  let [line_start, column_start] = getpos("'<")[1:2]
  let [line_end, column_end] = getpos("'>")[1:2]
  let lines = getline(line_start, line_end)
  if len(lines) == 0
    let prompt = ''
  else
    let lines[-1] = lines[-1][: column_end - 2]
    let lines[0] = lines[0][column_start - 1:]
    let prompt = join(lines, "\n")
    let prompt = prefix . prompt
  endif

  echo "Question sent, please wait ..."

  let temper = 0.2
  let output = GTPwithTimeout(prompt, temper)
  echo output
  if confirm("Write output at cursor position? (Y/n)", "&Yes\n&No") == 1
    normal m1}o
    call feedkeys("i")
    call feedkeys(output)
    call feedkeys("\<CR>\<Esc>'1}j")
  endif
endfunction

function! GptTest()
  normal me
  let [line_start, column_start] = getpos("'<")[1:2]
  let [line_end, column_end] = getpos("'>")[1:2]
  let lines = getline(line_start, line_end)
  if len(lines) == 0
    let prompt = ''
  else
    let lines[-1] = lines[-1][: column_end - 2]
    let lines[0] = lines[0][column_start - 1:]
    let prompt = join(lines, "\n")
    " let prompt = "improve the following:\n" . prompt
  endif

  echo "Question sent, please wait ..."

  " assign number 0.2 to variable temper
  let temper = 1.7
  let output = GTPwithTimeout(prompt, temper)
  echo output
  if confirm("Write output at cursor position? (Y/n)", "&Yes\n&No") == 1
    normal m1}o
    call feedkeys("i")
    call feedkeys(output)
    call feedkeys("\<CR>\<Esc>'1")
  endif
endfunction

function! GptMath()
  normal me
  let [line_start, column_start] = getpos("'<")[1:2]
  let [line_end, column_end] = getpos("'>")[1:2]
  let lines = getline(line_start, line_end)
  if len(lines) == 0
    let prompt = ''
  else
    let lines[-1] = lines[-1][: column_end - 2]
    let lines[0] = lines[0][column_start - 1:]
    let prompt = join(lines, "\n")
    let prompt = "Answer the question starting at the next paragraph, with all mathematical expressions typeset in Latex. Please use \\\[ as starting delimiter and \\\] as ending delimiter for displayed math.\n" . prompt
  endif

  echo "Question sent, please wait ..."

  let temper = 0.2
  let output = GTPwithTimeout(prompt, temper)
  echo output
  if confirm("Write output at cursor position? (Y/n)", "&Yes\n&No") == 1
    normal m1}o
    call feedkeys("i")
    call feedkeys(output)
    call feedkeys("\<CR>\<Esc>'1")
  endif
endfunction

function! GptCode()
  let prefix = "Programming language is " . &filetype . ", and the tabstop is " . &tabstop . ".\n"
  echo prefix
  normal me
  let [line_start, column_start] = getpos("'<")[1:2]
  let [line_end, column_end] = getpos("'>")[1:2]
  let lines = getline(line_start, line_end)
  if len(lines) == 0
    let prompt = ''
  else
    let lines[-1] = lines[-1][: column_end - 2]
    let lines[0] = lines[0][column_start - 1:]
    let prompt = join(lines, "\n")
    let prompt = prefix . prompt
  endif

  " echo "Question sent, please wait ..."

  let temper = 0.2
  let output = GTPwithTimeout(prompt, temper)
  echo output
  if confirm("Write output at cursor position? (Y/n)", "&Yes\n&No") == 1
    normal m1}o
    call feedkeys("i")
    call feedkeys(output)
    call feedkeys("\<CR>\<Esc>'1")
  endif
endfunction


command! Gpt call Gpt()
command! GptGen call GptGen()
command! GptGenLatest call GptGenLatest()
command! GptEdit call GptEdit()
command! GptTranslatetoE call GptTranslate("e")
command! GptTranslatetoC call GptTranslate("c")
command! GptTranslatetoH call GptTranslate("h")
command! GptTranslatetoF call GptTranslate("f")
command! GptTranslatetoI call GptTranslate("i")
command! GptAnalyzetoE call GptAnalyze("e")
command! GptAnalyzetoF call GptAnalyze("f")
command! GptGrammar call GptGrammar("n")
command! GptCorrection call GptGrammar("c")
command! GptClearnUp call GptClearnUp()
command! GptMath call GptMath()
command! GptCode call GptCode()
command! GptTest call GptTest()


