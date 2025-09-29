# LLM Guide & Local Setup Manual

## Background Knowledge

### LLM, Text Generation, Chat Bot

A Large Language Model (LLM) is a computational model that predicts the probability of tokens based on their context. For example, here is a sample input to a large language model:

> I have two things: an [1]

This is an incomplete sentence with a blank. The blank represents the target token position where the model predicts the probability of the next token based on the surrounding context — in this case, the rest of the incomplete sentence ("I have two things: an"). When it receives this input, the model calculates the probability of each possible token, given the context. 

The set of producible tokens depends on the specific model (specifically, its tokenizer) and can be thought of as a list of words the model can choose from to produce an output. 

To put it another way, if the large language model were like a native English speaker, its list of producible tokens would resemble entries in a dictionary such as Oxford or Merriam-Webster. 

For a simple example, if a model only knew three fruits — apple, pear, and orange — its output probabilities could look like this:

| Token  | Probability |
| ------ | ----------- |
| apple  | 0.7         |
| pear   | 0.2         |
| orange | 0.1         |

A typical output of a large language model takes the form of a list of token-probability pairs, as shown above. As discussed, which tokens appear in this list is determined by the LLM (specifically, its tokenizer). 

However, it is also important to consider what sources the model uses when predicting these probabilities. (Although I would like to explain in detail how the model arrives at its output step by step and formula by formula, this may be too technical at this point and is not necessary for effectively using the model.)

When this prediction process is repeated recursively across a sequence of token positions, it forms a probability tree. By searching this tree using specific rules, we can generate a sequence of tokens that form a coherent text. This process is called *text generation*.

For example, given the following context with four consecutive blanks at the end:

> I have two things: an [1 ] [2 ] [3 ] [4 ]

If we set the generation rule to **greedy search** (always selecting the token with the highest probability), the process works as follows:

First, the LLM predicts the probability of each token for the first blank:

| Token  | Probability |
| ------ | ----------- |
| apple  | 0.7         |
| pear   | 0.2         |
| orange | 0.1         |

Since we are using greedy search, **apple** is chosen as the token for the first blank. The context now becomes:

> I have two things: an apple [2 ] [3 ] [4 ]

Next, the LLM predicts the token for the second blank and produces these probabilities:

| Token | Probability |
| ----- | ----------- |
| and   | 0.9         |
| but   | 0.01        |
| or    | 0.01        |

Again, greedy search selects the highest-probability token, **and**, as the output for the second blank. 

The same process is repeated for the third and fourth blanks. After completing all steps, we end up with:

> I have two things: an apple and a pear

This is an example of text generation. Text generation works as a "continuation of writing," extending the text based on the given context. However, this continuation does not guarantee that the output will follow the user’s instructions or desired style. 

For instance, consider the following scenario:

If the model is instructed to generate text based on this prompt:

> You are a pirate and you are going to introduce the history of the printing press in 300 words.

The model might respond like this:

> It was a chilly winter evening in 1632 when the unthinkable happened. The streets of Strasbourg, Germany, were abuzz with the sound of drums and the smell of gunpowder wafted through the air. A pirate ship had sailed up the Rhine River, its black sails billowing in the wind.

While the response mentions the history of the printing press, it fails to adopt the perspective and voice of a pirate. The style and character requested in the prompt are ignored. This demonstrates that, in basic text generation, the model may not reliably follow instructions.

To enable a large language model to follow user instructions, it must be fine-tuned to align with the task of **question answering**. Question answering is similar to text generation, but it focuses on instruction following — providing a direct response to a prompt, rather than simply continuing the text.

This fine-tuning is typically done using either **instruction-based supervised fine-tuning (SFT)**, **reinforcement learning from human feedback (RLHF)**, or a combination of both. These methods transform a basic language model into a **chatbot**, such as ChatGPT, Claude, Llama, or DeepSeek.

Strictly speaking, these models are chatbots, not pure language models, because they no longer perform the original task of language modeling as defined earlier. However, in practice, people often blur the line between the two, so chatbots like ChatGPT, Claude, Llama, and DeepSeek are commonly referred to as large language models as well.

## Interacting with LLMs

Typically, users interact with a large language model (LLM) through a **server-client structure**, as shown below:

![Slide9.jpg](C:\Users\MiraMoe\Desktop\Markdown\InferringInterfaceFig.jpg)

### Open-parameters and Closed-parameters LLM

Parameters of an LLM (sometimes also referred to as its weights and biases) are the numerical representation of the knowledge the model has obtained through training. They are of vital importance during inference, because the LLM relies on these parameters to generate accurate and meaningful responses. 

Based on the accessibility of their parameters, large language models can be divided into **open-parameter LLMs** and **closed-parameter LLMs**.

**Closed-parameter LLMs** are likely the ones most familiar to new users. Examples include **ChatGPT**, **Claude**, and **Gemini**. These models are provided to users via a **Graphical User Interface (GUI)** or an **Application Programming Interface (API)**, so users do not need to worry about hosting the LLM themselves. 

The companies that develop these models host them on their own servers, and users are not allowed to host their own versions. This is because the parameters are closed — meaning they are not publicly accessible. In simple terms, you **cannot download** ChatGPT, Claude, Gemini, or any other closed-parameter model to run it locally.

Moreover, users do not have full control over the model or their data input, since all text must be uploaded through the GUI or API to the hosting company’s servers. While most **End User License Agreements (EULAs)** emphasize privacy protection, your data must at least pass through these companies before the model can generate a response.

---

**Open-parameter LLMs**, by contrast, have their parameters freely available on the internet. These parameters can be **downloaded**, **loaded locally**, fine-tuned, or tweaked (e.g., activation manipulation) for a user’s own purposes. 

While some models can also be found on their respective publication repositories, most of today’s high-performing open-parameter LLMs are hosted on [**Hugging Face**](https://huggingface.co), which is the largest and most well-known platform for AI model sharing.

Using an open-parameter LLM gives the user **total control** of the model. If needed, you can confine, inspect, and manipulate any detail of the model’s operation at any stage. These models can be run entirely locally, meaning that once a model is downloaded, **no internet connection is required**, and all text you provide stays on your own PC. This greatly enhances privacy, which is especially useful when working with data that cannot be published for ethical or confidentiality reasons.

---

However, using open-parameter LLMs comes with **trade-offs**.  

- **Setup** – Users must find their own hosting server or use a software library to start the inference process.  
- **Complexity** – This makes open-parameter models more complicated to use compared to closed-parameter models.  
- **Hardware requirements** – Running an LLM locally requires a powerful computer.  

Typically, you will need **at least 8GB of memory** and a **graphics card (GPU)** to run even the smallest open-parameter models, such as **Llama 1B**. Without sufficient resources, performance will be slow or unstable.

## Ollama Setup

Ollama is an open-source LLM server program that allows you to host LLMs locally on your PC or laptop. Installation binaries are available for OSX, Windows, and Linux, so regardless of your operating system, Ollama is available for you.

Ollama can be used through the terminal (command line, cmd), via a graphical user interface (GUI), or through an API.

### Installation

To install Ollama, first visit its official website:

> [https://ollama.com](https://ollama.com)

and follow the instructions for your specific operating system.

#### Windows

You have two options to install Ollama on Windows:

**Option 1:** Go to this page:

> [Download Ollama on Windows](https://ollama.com/download/Windows)

Click the download button. Once the installer is downloaded, double-click it to start and follow the on-screen instructions.

**Option 2:** Press **Ctrl + R** to open the *Run* dialog. Type:

> cmd

and click **OK**.  
(If you have administrative privileges, press **Ctrl + Shift + Enter** to run as administrator.)

This will open a Windows command line.

In the command line, type:

> winget install ollama

Press **Enter** to start the installation.  
You may be prompted to accept the End User License Agreement (EULA); type **y** (yes) to proceed.

#### Linux

To install Ollama on Linux, press **Ctrl + Alt + T** to open a terminal. Then run:

> curl -fsSL https://ollama.com/install.sh | sh

This will automatically download and install Ollama.  
If prompted for administrator privileges, use the following instead:

> sudo curl -fsSL https://ollama.com/install.sh | sh

Note: You may be asked to enter your admin password when using `sudo`.

#### OSX

To install Ollama on OSX, go to:

> [Download Ollama on macOS](https://ollama.com/download/mac)

and follow the instructions provided.

---

### Ollama Command Line Interface (CLI)

Once installed successfully, you can use Ollama in several ways, with the **command line interface (CLI)** being the most fundamental.

The CLI lets you interact with Ollama, check its status, download and run models, and manage your local models.

To open a command line or terminal:

- **Windows:** Press **Ctrl + R**, type `cmd`, and click **OK**.  
- **Linux:** Press **Ctrl + Alt + T**.  
- **OSX:** Launch the **Terminal** application from Launchpad or Spotlight.

Once open, type:

> ollama

You should see a brief help message listing available sub-commands, for example:

> Usage:  
>  ollama [flags]  
>  ollama [command]  
> 
> Available Commands:  
>  serve Start Ollama  
>  create Create a model from a Modelfile  
>  show Show information for a model  
>  run Run a model  
>  stop Stop a running model  
>  pull Pull a model from a registry  
>  push Push a model to a registry  
>  list List models  
>  ps List running models  
>  cp Copy a model  
>  rm Remove a model  
>  help Help about any command  
> 
> Flags:  
>  -h, --help Help for Ollama  
>  -v, --version Show version information  
> 
> Use "ollama [command] --help" for more information about a command.

If you don’t see this output, double-check your installation. If the issue persists, seek assistance.

The following sections walk you through basic Ollama usage. It’s recommended to try each command as you read.

---

#### Start Ollama

Ollama usually starts automatically with your operating system or right after installation.  
If it is not running, start it manually with:

> ollama serve

**Note:** Only one Ollama instance can run at a time.  
If you see this error:

> Error: listen tcp 127.0.0.1:11434: bind: address already in use

it typically means Ollama is already running. (In rare cases, another program might be using port `11434`.)

---

#### Download a Model

To use a model, you must download it first.  
Check here for the full list of available models:

> [Ollama Search](https://ollama.com/search)

- For laptops or low-spec home PCs, choose a smaller model such as **1B** or **3B**.  
- For workstations or servers (e.g., BlueBEAR), you can use larger models.

Once you’ve selected a model, run:

> ollama pull [MODEL_NAME]

For example, to download the model `llama3.2:1b`, run:

> ollama pull llama3.2:1b

---

#### Check Downloaded Models

To list all downloaded models, use:

> ollama list

This will display each model along with relevant information.

---

#### Run a Model

To run a downloaded model, type:

> ollama run [MODEL_NAME]

For example:

> ollama run llama3.2:1b

When the model is ready, you’ll see:

> > > > send a message ( /? for help)

You can now type prompts directly into the terminal.  
The model will generate responses in the same window.

To exit the chat session, type:

> /bye

**Important:**  
`/bye` **does not stop the model**, it only closes the dialogue.  
To fully stop the model, see below.

---

#### Stop a Model

To stop a running model, use:

> ollama stop [MODEL_NAME]

Example:

> ollama stop llama3.2:1b

---

#### Check Running Models

If you forget which model is running, or suspect a model was started by another program, type:

> ollama ps

This will show a list of currently active models.

---

## Ollama with GUI

Beyond the CLI, a more user-friendly way to use Ollama is through a **graphical user interface (GUI)**.  
A GUI allows you to interact with your local model in a style similar to ChatGPT.

Before using the GUI, make sure a model is running.  
For example, start the `llama3.2:1b` model with:

> ollama run llama3.2:1b

Next, open your web browser and install the **Page Assist** extension.

- **Firefox:** [Page Assist for Firefox](https://addons.mozilla.org/en-US/firefox/addon/page-assist/)  
- **Chrome:** [Page Assist for Chrome](https://chromewebstore.google.com/detail/page-assist-a-web-ui-for/jfgfiigpkhlkbnfnbobbkinehhfdhndo)  
  (Or search for "Page Assist" in the Chrome Web Store.)

After installing, you’ll see Page Assist in your browser’s extensions list.  
*Tip:* Pin it for easy access.

Click the extension icon to launch it. It will automatically connect to your local Ollama instance and the running model.

---

Now you have a fully local LLM, completely under your control.  
Since it runs on your own PC, all data stays private, free from outside censorship, and with full transparency.
