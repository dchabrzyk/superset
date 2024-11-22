import polib
import requests
import os
import re

DEEPL_API_URL = "https://api.deepl.com/v2/translate"
DEEPL_API_KEY = "<YOUR-API-KEY>"  # Replace with your DeepL API key

# Regular expression to match variables like %(var)s
VARIABLE_REGEX = re.compile(r"%\(([^)]+)\)s")

def translate_text(text, target_lang, source_lang=None):
    """
    Translates text using the DeepL API, preserving variables in the format %(var)s.
    :param text: Text to translate
    :param target_lang: Target language (e.g., 'DE' for German, 'FR' for French)
    :param source_lang: Source language (optional)
    :return: Translated text
    """
    # Find all variables in the text
    variables = VARIABLE_REGEX.findall(text)

    # Replace variables with unique markers
    for i, variable in enumerate(variables):
        text = text.replace(f"%({variable})s", f"__VAR{i}__")

    # Translate the text without variables
    data = {
        'auth_key': DEEPL_API_KEY,
        'text': text,
        'target_lang': target_lang
    }

    if source_lang:
        data['source_lang'] = source_lang

    response = requests.post(DEEPL_API_URL, data=data)

    if response.status_code == 200:
        result = response.json()
        translated_text = result['translations'][0]['text']

        # Replace unique markers back with original variables
        for i, variable in enumerate(variables):
            translated_text = translated_text.replace(f"__VAR{i}__", f"%({variable})s")

        return translated_text
    else:
        raise Exception(f"Error during translation: {response.status_code} - {response.text}")


def translate_po_file(input_file, output_file, target_lang, source_lang=None):
    """
    Translates a .po file using the DeepL API.
    :param input_file: Path to the input .po file
    :param output_file: Path to the output .po file (translated)
    :param target_lang: Target language code (e.g., 'DE', 'FR')
    :param source_lang: Source language code (optional)
    """
    po = polib.pofile(input_file)

    for entry in po:
        if entry.msgid and not entry.msgstr:  # Translate only untranslated strings
            try:
                translated_text = translate_text(entry.msgid, target_lang, source_lang)
                entry.msgstr = translated_text
                print(f"Translated: {entry.msgid} -> {translated_text}")
            except Exception as e:
                print(f"Failed to translate {entry.msgid}: {e}")

    po.save(output_file)
    print(f"Translation complete. Translated file saved to {output_file}")



if __name__ == "__main__":
    input_po_path = "en/LC_MESSAGES/messages.po"  # Replace with your input .po file
    output_po_path = "pl/LC_MESSAGES/messages_1.po"  # Replace with your desired output.po
    target_language = "PL"  # Replace with the target language code
    source_language = "EN"  # Optionally set a source language, or leave it as None

    translate_po_file(input_po_path, output_po_path, target_language, source_language)
