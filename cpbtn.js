function copyPreTextToClipboard(orgSrcContainer, classes) {
  let preTag;
  for (const classItem of classes) {
    preTag = orgSrcContainer.querySelector(`pre.${classItem}`);
    if (preTag) break;
  }

  if (preTag) {
    const textContent = preTag.textContent;

    // Get class name of the container
    const containerClass = orgSrcContainer.className;

    // Create a temporary textarea element to copy the text
    const tempTextarea = document.createElement('textarea');
    tempTextarea.value = textContent;

    // Append the textarea to the document
    document.body.appendChild(tempTextarea);

    // Select the text within the textarea
    tempTextarea.select();

    // Copy the selected text to the clipboard
    document.execCommand('copy');

    // Remove the temporary textarea
    document.body.removeChild(tempTextarea);

    console.log('Text copied to clipboard:', textContent);
    console.log('Class name of container:', containerClass);

    // Change button label to "Copied"
    const button = orgSrcContainer.querySelector('button');
    if (button) {
      button.textContent = '📋 ✅ Copied';
      button.disabled = true; // Disable the button after copying

      // Revert button to its initial state after 3 seconds
      setTimeout(() => {
        button.textContent = '📋 Copy Text';
        button.disabled = false; // Enable the button after timeout
      }, 3000);
    }
  } else {
    console.log('Pre tag with specified classes not found inside org-src-container');
  }
}

function createCopyButtonForDivs() {
  const orgSrcContainers = document.querySelectorAll('div.org-src-container');
  orgSrcContainers.forEach((container) => {
    const button = document.createElement('button');
    button.textContent = '📋 Copy Text';
    button.addEventListener('click', () => {
				const classesToSearch = [
						'src.src-emacs-lisp',
						'src.src-python',
						'src.src-javascript',
						'src.src-c',
						'src.src-html',
						'src.src-css']; // Add more classes/languages as needed
				copyPreTextToClipboard(container, classesToSearch);
    });

    container.appendChild(button);
  });
}

// Call the function to create copy buttons in each org-src-container div
createCopyButtonForDivs();
