/*******************************************************************************
 * Copyright (c) 2005, 2007 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *     Frank Benoit <benoit@tionex.de>
 *******************************************************************************/
module jface.snippets.wizard.Snippet047WizardWithLongRunningOperation;

import org.eclipse.jface.viewers.ArrayContentProvider;
import org.eclipse.jface.viewers.ISelectionChangedListener;
import org.eclipse.jface.viewers.SelectionChangedEvent;
import org.eclipse.jface.viewers.TableViewer;
import org.eclipse.jface.wizard.IWizardPage;
import org.eclipse.jface.wizard.Wizard;
import org.eclipse.jface.wizard.WizardDialog;
import org.eclipse.jface.wizard.WizardPage;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.ProgressBar;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.jface.operation.IRunnableWithProgress;
import java.lang.all;
import java.util.ArrayList;

import java.lang.Thread;
import tango.text.convert.Format;

import org.eclipse.jface.operation.ModalContext;

/**
 * Example how to load data from a background thread into a TableViewer
 *
 * @author Tom Schindl <tom.schindl@bestsolution.at>
 * @since 1.0
 */
public class Snippet047WizardWithLongRunningOperation {

    private static class MyWizard : Wizard {

        private int loadingType;

        public this(int loadingType) {
            this.loadingType = loadingType;
        }

        /*
         * (non-Javadoc)
         *
         * @see org.eclipse.jface.wizard.Wizard#addPages()
         */
        public void addPages() {
            addPage(new MyWizardPageThread("Thread Page", loadingType));
            addPage(new MyWizardPage("Standard Page"));
        }

        public bool performFinish() {
            return true;
        }

        /*
         * (non-Javadoc)
         *
         * @see org.eclipse.jface.wizard.Wizard#canFinish()
         */
        public bool canFinish() {
            IWizardPage[] pages = getPages();
            for (int i = 0; i < pages.length; i++) {
                if (!pages[i].isPageComplete()) {
                    return false;
                }
            }

            return true;
        }

    };

    private static class MyWizardPage : WizardPage {

        protected this(String pageName) {
            super(pageName);
            setTitle(pageName);
        }

        public /+override+/ void createControl(Composite parent) {
            Composite comp = new Composite(parent, SWT.NONE);
            setControl(comp);
        }
    }

    private static class MyWizardPageThread : WizardPage {
        private int loadingType;
        private bool loading = true;
        private TableViewer v;

        protected this(String pageName, int loadingType) {
            super(pageName);
            this.loadingType = loadingType;
            setTitle(pageName);
        }

        public /+override+/ void createControl(Composite parent) {
            auto mt = new MyThread();
            mt.parent = parent;

            mt.comp = new Composite(parent, SWT.NONE);
            mt.comp.setLayout(new GridLayout(1, false));

            v = new TableViewer(mt.comp, SWT.FULL_SELECTION);
            v.setContentProvider(new ArrayContentProvider!(Object)());
            v.getTable().setLayoutData(new GridData(GridData.FILL_BOTH));
            v.addSelectionChangedListener(new class ISelectionChangedListener {

                public void selectionChanged(SelectionChangedEvent event) {
                    getWizard().getContainer().updateButtons();
                }

            });

            mt.barContainer = new Composite(mt.comp, SWT.NONE);
            mt.barContainer.setLayoutData(new GridData(GridData.FILL_HORIZONTAL));
            mt.barContainer.setLayout(new GridLayout(2, false));

            Label l = new Label(mt.barContainer, SWT.NONE);
            l.setText("Loading Data");

            mt.bar = new ProgressBar(mt.barContainer,
                    (loadingType == 1) ? SWT.INDETERMINATE : SWT.NONE);
            mt.bar.setLayoutData(new GridData(GridData.FILL_HORIZONTAL));

            if (loadingType == 2) {
                mt.bar.setMaximum(10);
            }

            setControl(mt.comp);
            dialog.run( true, true, dgIRunnableWithProgress(&mt.threadWork));
        }
        class MyThread {
            private Composite parent;
            private Composite barContainer;
            private Composite comp;
            private ProgressBar bar;

            private void threadWork(){
                if (loadingType == 1) {
                    try {
                        Thread.sleep(10_000);
                        ArrayList ms = new ArrayList();
                        for (int i = 0; i < 10; i++) {
                            ms.add(new MyModel(i));
                        }

                        if (v.getTable().isDisposed()) {
                            return;
                        }

                        parent.getDisplay().asyncExec(dgRunnable((ArrayList ms_){
                                v.setInput(ms_);
                                (cast(GridData) barContainer.getLayoutData()).exclude = true;
                                comp.layout(true);
                        }, ms ));
                    } catch (InterruptedException e) {
                        // TODO Auto-generated catch block
                        ExceptionPrintStackTrace(e);
                    }
                } else {
                    ArrayList ms = new ArrayList();
                    parent.getDisplay().syncExec( dgRunnable( (ArrayList ms_){
                        v.setInput(ms_);
                    }, ms ));

                    for (int i = 0; i < 10; i++) {
                        int j = i;
                        if (v.getTable().isDisposed()) {
                            return;
                        }
                        parent.getDisplay().asyncExec( dgRunnable( (int j_){
                            MyModel tmp = new MyModel(j_);
                            v.add(tmp);
                            ms.add(tmp);
                            bar.setSelection(j_ + 1);
                        }, j ));

                        try {
                            Thread.sleep(1_000);
                        } catch (InterruptedException e) {
                            // TODO Auto-generated catch block
                            ExceptionPrintStackTrace(e);
                        }
                    }

                    parent.getDisplay().asyncExec(dgRunnable( {

                            (cast(GridData) barContainer.getLayoutData()).exclude = true;
                            comp.layout(true);
                    }));
                }

                parent.getDisplay().syncExec(dgRunnable( {
                    loading = false;
                    getWizard().getContainer().updateButtons();
                }));
            }
        }
        public bool isPageComplete() {
            return !loading && !v.getSelection().isEmpty();
        }

    }

    private static class MyModel {
        private int index;

        public this(int index) {
            this.index = index;
        }

        public String toString() {
            return Format("Item-{}", index);
        }
    }

    static Shell shell;
    static WizardDialog dialog;
    public static void main(String[] args) {
        Display display = new Display();

        shell = new Shell(display);
        shell.setLayout(new FillLayout());

        Button b = new Button(shell, SWT.PUSH);
        b.setText("Load in one Chunk");
        b.addSelectionListener(new class SelectionAdapter {

            public void widgetSelected(SelectionEvent e) {
                dialog = new WizardDialog(shell, new MyWizard(1));
                dialog.open();
            }

        });

        b = new Button(shell, SWT.PUSH);
        b.setText("Load Item by Item");
        b.addSelectionListener(new class SelectionAdapter {

            public void widgetSelected(SelectionEvent e) {
                dialog = new WizardDialog(shell, new MyWizard(2));
                dialog.open();
            }

        });

        shell.open();

        while (!shell.isDisposed()) {
            if (!display.readAndDispatch())
                display.sleep();
        }

        display.dispose();
    }
}

void main(){
    Snippet047WizardWithLongRunningOperation.main(null);
}
