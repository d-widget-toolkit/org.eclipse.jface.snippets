/*******************************************************************************
 * Copyright (c) 2006 Tom Schindl and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Tom Schindl - initial API and implementation
 *******************************************************************************/

module org.eclipse.jface.snippets.window.Snippet031TableStaticTooltip;

import org.eclipse.jface.viewers.IStructuredContentProvider;
import org.eclipse.jface.viewers.ITableLabelProvider;
import org.eclipse.jface.viewers.LabelProvider;
import org.eclipse.jface.viewers.TableViewer;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.jface.window.DefaultToolTip;
import org.eclipse.jface.window.ToolTip;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.TableColumn;

import java.lang.all;
import tango.text.convert.Format;


/**
 * Example how one can create a tooltip which is not recreated for every table
 * cell
 *
 * @author Tom Schindl <tom.schindl@bestsolution.at>
 *
 */
public class Snippet031TableStaticTooltip {
    private static Image[] images;

    private class MyContentProvider : IStructuredContentProvider {

        /*
         * (non-Javadoc)
         *
         * @see org.eclipse.jface.viewers.IStructuredContentProvider#getElements(java.lang.Object)
         */
        public Object[] getElements(Object inputElement) {
            return arrayFromObject!(MyModel)( inputElement );
        }

        /*
         * (non-Javadoc)
         *
         * @see org.eclipse.jface.viewers.IContentProvider#dispose()
         */
        public void dispose() {

        }

        /*
         * (non-Javadoc)
         *
         * @see org.eclipse.jface.viewers.IContentProvider#inputChanged(org.eclipse.jface.viewers.Viewer,
         *      java.lang.Object, java.lang.Object)
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
            return Format("Item {}", this.counter );
        }
    }

    public class MyLabelProvider : LabelProvider,
            ITableLabelProvider {

        public Image getColumnImage(Object element, int columnIndex) {
            if (columnIndex == 1) {
                return images[(cast(MyModel) element).counter % 4];
            }

            return null;
        }

        public String getColumnText(Object element, int columnIndex) {
            return Format("Column {} => {}", columnIndex, element.toString());
        }

    }

    private static Image createImage(Display display, int red, int green,
            int blue) {
        Color color = new Color(display, red, green, blue);
        Image image = new Image(display, 10, 10);
        GC gc = new GC(image);
        gc.setBackground(color);
        gc.fillRectangle(0, 0, 10, 10);
        gc.dispose();

        return image;
    }

    TableViewer v;
    public this(Shell shell) {
        v = new TableViewer(shell, SWT.BORDER
                | SWT.FULL_SELECTION);
        v.setLabelProvider(new MyLabelProvider());
        v.setContentProvider(new MyContentProvider());

        TableColumn column = new TableColumn(v.getTable(), SWT.NONE);
        column.setWidth(200);
        column.setText("Column 1");

        column = new TableColumn(v.getTable(), SWT.NONE);
        column.setWidth(200);
        column.setText("Column 2");

        MyModel[] model = createModel();
        v.setInput(new ArrayWrapperObject(arraycast!(Object)(model)));
        v.getTable().setLinesVisible(true);
        v.getTable().setHeaderVisible(true);

        DefaultToolTip toolTip = new DefaultToolTip(v.getControl(),
                ToolTip.NO_RECREATE, false);
        toolTip.setText("Hello World\nHello World");
        toolTip.setBackgroundColor(v.getTable().getDisplay().getSystemColor(
                SWT.COLOR_RED));
        toolTip.setShift(new Point(10, 5));
    }

    private MyModel[] createModel() {
        MyModel[] elements = new MyModel[10];

        for (int i = 0; i < 10; i++) {
            elements[i] = new MyModel(i);
        }

        return elements;
    }

    /**
     * @param args
     */
    public static void main(String[] args) {
        Display display = new Display();

        images = new Image[4];
        images[0] = createImage(display, 0, 0, 255);
        images[1] = createImage(display, 0, 255, 255);
        images[2] = createImage(display, 0, 255, 0);
        images[3] = createImage(display, 255, 0, 255);

        Shell shell = new Shell(display);
        shell.setLayout(new FillLayout());
        new Snippet031TableStaticTooltip(shell);
        shell.open();

        while (!shell.isDisposed()) {
            if (!display.readAndDispatch())
                display.sleep();
        }

        for (int i = 0; i < images.length; i++) {
            images[i].dispose();
        }

        display.dispose();

    }

}

void main(){
    Snippet031TableStaticTooltip.main(null);
}
