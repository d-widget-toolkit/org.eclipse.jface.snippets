/*******************************************************************************
 * Copyright (c) 2006 Tom Schindl and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Tom Schindl - initial API and implementation
 * Port to the D programming language:
 *     wbaxter at gmail dot com
 *******************************************************************************/

module org.eclipse.jface.snippets.viewers.Snippet001TableViewer;

import org.eclipse.jface.viewers.IStructuredContentProvider;
import org.eclipse.jface.viewers.LabelProvider;
import org.eclipse.jface.viewers.TableViewer;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.SWT;

import java.lang.all;
import java.util.ArrayList;

import tango.util.Convert;

/**
 * A simple TableViewer to demonstrate usage
 *
 * @author Tom Schindl <tom.schindl@bestsolution.at>
 *
 */
public class Snippet001TableViewer {
	private class MyContentProvider : IStructuredContentProvider {

		/* (non-Javadoc)
		 * @see org.eclipse.jface.viewers.IStructuredContentProvider#getElements(java.lang.Object)
		 */
		public Object[] getElements(Object inputElement) {
			return (cast(ArrayList)inputElement).toArray;
		}

		/* (non-Javadoc)
		 * @see org.eclipse.jface.viewers.IContentProvider#dispose()
		 */
		public void dispose() {

		}

		/* (non-Javadoc)
		 * @see org.eclipse.jface.viewers.IContentProvider#inputChanged(org.eclipse.jface.viewers.Viewer, java.lang.Object, java.lang.Object)
		 */
		public void inputChanged(Viewer viewer, Object oldInput, Object newInput) {

		}

	}

	public class MyModel {
		public int counter;

		public this(int counter) {
			this.counter = counter;
		}

		public String toString() {
			return "Item " ~ to!(char[])(this.counter);
		}
	}

	public this(Shell shell) {
		final TableViewer v = new TableViewer(shell);
		v.setLabelProvider(new LabelProvider());
		v.setContentProvider(new MyContentProvider());
		ArrayList model = createModel();
		v.setInput(model);
		v.getTable().setLinesVisible(true);
	}

	private ArrayList createModel() {
		ArrayList elements = new ArrayList(10);

		for( int i = 0; i < 10; i++ ) {
			elements.add( new MyModel(i));
		}

		return elements;
	}

}

void main()
{
    Display display = new Display ();
    Shell shell = new Shell(display);
    shell.setLayout(new FillLayout());
    new Snippet001TableViewer(shell);
    shell.open ();

    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }

    display.dispose ();

}

