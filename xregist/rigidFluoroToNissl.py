import numpy as np
import SimpleITK as sitk
import os, math, sys
import ndreg2D

dimension = 2
affine = sitk.AffineTransform(dimension)
identityAffine = list(affine.GetParameters())
identityDirection = list(affine.GetMatrix())
zeroOrigin = [0]*dimension
zeroIndex = [0]*dimension

def main():
    target = sitk.ReadImage(sys.argv[1], sitk.sitkFloat32)
    template = sitk.ReadImage(sys.argv[2], sitk.sitkFloat32)
    translation = registrationTranslation(target, template, identityAffine, 0.4, 0.02, 0.0005)
    translation = registrationTranslation(target, template, translation, 0.35, 0.005, 0.0001)
    euler2d = registrationEuler2D(target, template, translation, 0.2, 0.02, 0.00005)
    euler2d = registrationEuler2D(target, template, euler2d, 0.06, 0.005, 0.000025)
    euler2d = registrationEuler2D(target, template, translation, 0.04, 0.002, 0.000025)
    outImg = ndreg2D.imgApplyAffine2D(template, euler2d, target.GetSize())
    sitk.WriteImage(outImg, sys.argv[3])
    mytransformfile = open(sys.argv[4], "w")
    for item in euler2d:
        mytransformfile.write("%s\n" % item)
    
    mytransformfile.close()
    return

def registrationTranslation(target, template, initialTransform, smoothingRadius, mylearningRate, myminStep):
    interpolator = sitk.sitkLinear
    transtransform = sitk.TranslationTransform(dimension)
    transtransform.SetOffset(initialTransform[4:6])
    registration = sitk.ImageRegistrationMethod()
    registration.SetInterpolator(interpolator)
    registration.SetInitialTransform(transtransform)
    numHistogramBins = 64
    registration.SetMetricAsMattesMutualInformation(numHistogramBins)
    iterations = 10000
    registration.SetOptimizerAsRegularStepGradientDescent(learningRate=mylearningRate,numberOfIterations=iterations,estimateLearningRate=registration.EachIteration,minStep=myminStep)
    registration.Execute(sitk.SmoothingRecursiveGaussian(target,smoothingRadius),sitk.SmoothingRecursiveGaussian(template,smoothingRadius) )
    translation = identityAffine[0:dimension**2] + list(transtransform.GetOffset())
    return translation

def registrationEuler2D(target, template, initialTransform, smoothingRadius, mylearningRate, myminStep):
    interpolator = sitk.sitkLinear
    transform = sitk.Euler2DTransform()
    transform.SetTranslation(initialTransform[4:6])
    transform.SetMatrix(initialTransform[0:4])
    registration = sitk.ImageRegistrationMethod()
    registration.SetInterpolator(interpolator)
    registration.SetInitialTransform(transform)
    numHistogramBins = 64
    registration.SetMetricAsMattesMutualInformation(numHistogramBins)
    iterations = 10000
    registration.SetOptimizerAsRegularStepGradientDescent(learningRate=mylearningRate,numberOfIterations=iterations,estimateLearningRate=registration.EachIteration,minStep=myminStep)
    registration.Execute(sitk.SmoothingRecursiveGaussian(target,smoothingRadius),sitk.SmoothingRecursiveGaussian(template,smoothingRadius) )
    euler2d = list(transform.GetMatrix()) + list(transform.GetTranslation())
    return euler2d

if __name__=="__main__":
    main()

